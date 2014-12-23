#coding=utf-8
from pyramid.view import view_defaults, view_config
from pyramid.security import remember,forget
from pyramid.httpexceptions import HTTPFound

from hzsxactivitymanagesite.resources.models import JSONObject, FormObject
from hzsxactivitymanagesite.libs.simpleform import Form, State
from hzsxactivitymanagesite.business.validators import *
from hzsxactivitymanagesite.exceptions import APIError, PageError
from hzsxactivitymanagesite.token import Token
from .common import user_snap

import qiniu, qiniu.conf, qiniu.rs
import time, requests

from pymongo import ASCENDING, DESCENDING
from bson.dbref import DBRef
from logging import getLogger
from bson import objectid

log = getLogger(__name__)


def includeme(config):
    config.scan(__name__)
    config.add_route('index', '/')
    config.add_route('admin', '/admin')
    config.add_route('screen', '/screen/{action}')
    config.add_route('pass', '/pass/{action}')
    config.add_route('manage', '/manage/{action}')
    config.add_route('api', '/api/{action}')
    config.add_route('proxy', '/proxy/{action}')

@view_config(route_name='index', renderer='manage/login.mako')
def index(request):
    if request.user:
        return HTTPFound(location='manage/home')
    return dict()

@view_config(route_name='admin', renderer='manage/login.mako')
def admin(request):
    return dict()

@view_defaults(route_name='screen', permission=None)
class ScreenView(object):
    def __init__(self, request):
        self.request = request
        self.db = request.db
    
    @view_config(renderer='shikewall/home.mako', match_param=('action=home'))
    def home(self):
        return dict()
        
     
    @view_config(renderer='shikewall/wall.mako', match_param=('action=wall'))
    def wall(self):
        return dict()
    
    @view_config(renderer='shikewall/lottery.mako', match_param=('action=lottery'))
    def lottery(self):
        return dict()

@view_defaults(route_name='pass')
class PassView(object):
    def __init__(self, request):
        self.request = request
        self.db = request.db

    @view_config(renderer='json', match_param=('action=login'))
    def login(self):
        validators = dict(phone=PhoneNumber(), password=Password())
        form = Form(self.request,validators=validators,state=State(request=self.request))
        if form.validate(force_validate=True):
            data = JSONObject(form.data)
            user = self.db.user.find_one({"phone": data.phone, "password": data.password}, {'phone': False, 'password': False, 'status': False})
            if user:
                headers = remember(self.request, str(user.get('_id')))
                self.request.response_headerlist=headers
                return dict(result=1)
            else:
                raise APIError(20003, u'用户名或密码错误', path=self.request.path)
        return FormObject(form.errors)
    
    @view_config(renderer='json', match_param=('action=logout'))
    def logout(self):
        headers=forget(self.request)
        self.request.session.clear()
        return HTTPFound(location=self.request.route_url('admin'), headers=headers)

@view_defaults(route_name='manage', permission='user')
class ManageView(object):
    
    def __init__(self, request):
        self.request = request
        self.db = request.db
    
    @view_config(renderer='/manage/event_table_list.mako', match_param=('action=home'))
    def home(self):
        validators = dict(
                          page=fe.validators.Int(if_missing=1, if_empty=1),
                          isdeleted=fe.Pipe(fe.validators.Int(if_missing=-1, if_empty=-1), fe.validators.OneOf([-1,0,1])),
                          keyword = fe.validators.UnicodeString(if_missing="", if_empty="", strip=True),
                          starttime = fe.validators.Int(if_missing=0, if_empty=0),
                          endtime = fe.validators.Int(if_missing=0, if_empty=0),
                          )
        form = Form(self.request,validators=validators, state=State(request=self.request))
        if form.validate(force_validate=True):
            page = form.data.get('page')
            isdeleted = form.data.get('isdeleted')
            keyword = form.data.get('keyword')
            starttime = form.data.get('starttime')
            endtime = form.data.get('endtime')
            
            page = page if page >0 else 1
            pageSize = 20
            
            condition = {'user.$id': self.request.user.id}
            if isdeleted==1 :
                condition.update({'isdeleted': True})
            if keyword and len(keyword)>0:
                condition.update({'title': {'$regex': ".*%s.*" % keyword, "$options": "i"}})
            if starttime!=0 and endtime!=0 and starttime<endtime:
                condition.update({'time.update': {'$gt': starttime, '$lt': endtime}})
            elif starttime!=0:
                condition.update({'time.update': {'$gt': starttime}})
            elif endtime!=0:
                condition.update({'time.update': {'$lt': endtime}})
            
            lists = self.db.event_table.find(condition).sort([('time.update', DESCENDING)])
            count = lists.count()
            lists = lists.skip((page-1)*pageSize).limit(pageSize)
            items = []
            for item in lists:
                user = item.get('user')
                user = self.db.dereference(user)
                item.update({'user': user})
                items.append(item)
            return dict(lists= items, count=count, page=page)
        return FormObject(form.errors)
    
    @view_config(renderer='/manage/event_table_create.mako', match_param='action=event_table_create')
    def event_table_create(self):
        return {}
    
    @view_config(renderer='/manage/event_table_edit.mako', match_param='action=event_table_edit')
    def event_table_edit(self):
        validators = dict(tid=ObjectIdConverter())
        form = Form(self.request,validators=validators, state=State(request=self.request))
        if form.validate(force_validate=True):
            tid = form.data.get("tid")
            table = self.db.event_table.find_one({'_id': tid})
            if table:
                return dict(table=table)
            else:
                raise PageError(u'该活动不存在')
        return FormObject(form.errors)
    
    @view_config(renderer='manage/event_list.mako', match_param=('action=event_list'))
    def event_list(self):
        validators = dict(
                          page=fe.validators.Int(if_missing=1, if_empty=1),
                          keyword = fe.validators.UnicodeString(if_missing="", if_empty="", strip=True),
                          starttime = fe.validators.Int(if_missing=0, if_empty=0),
                          endtime = fe.validators.Int(if_missing=0, if_empty=0),
                          )
        form = Form(self.request,validators=validators, state=State(request=self.request))
        if form.validate(force_validate=True):
            page = form.data.get('page')
            keyword = form.data.get('keyword')
            starttime = form.data.get('starttime')
            endtime = form.data.get('endtime')
            tid =  self.request.params.get("tid", "")
            userid =  self.request.params.get("userid", "")
            
            page = page if page >0 else 1
            pageSize = 20
            ret = dict()
                        
            condition = {'user.$id': self.request.user.id}            
            if ObjectId.is_valid(userid):
                user = self.db.user.find_one({'_id': ObjectId(userid)})
                if user:
                    alarms = self.db.alarm.find({'user.$id': ObjectId(userid)},{'event': True})
                    eventids = [alarm.get('event').id for alarm in alarms]
                    if len(eventids)>0:
                        condition.update({'_id': {'$in': eventids}})
                    ret.update({'user': user})
            if ObjectId.is_valid(tid):
                table = self.db.event_table.find_one({'_id': ObjectId(tid)})
                if table:
                    condition.update({'table.$id': ObjectId(tid)})
                    ret.update({'table':table})
            if keyword and len(keyword)>0:
                condition.update({'$or': [
                                          {'content': {'$regex':  ".*%s.*" % keyword, "$options": "i"}},
                                          {'title': {'$regex':  ".*%s.*" % keyword, "$options": "i"}}
                                          ]})
            if starttime!=0 and endtime!=0 and starttime<endtime:
                condition.update({'time.create': {'$gt': starttime, '$lt': endtime}})
            elif starttime!=0:
                condition.update({'time.create': {'$gt': starttime}})
            elif endtime!=0:
                condition.update({'time.create': {'$lt': endtime}})
            
            lists = self.db.event.find(condition, {'content': False}).sort([('alarm.starttime', DESCENDING), ('alarm.endtime', DESCENDING)])
            count = lists.count()
            lists = lists.skip((page-1)*pageSize).limit(pageSize)
            events = []
            for item in lists:
                user = item.get('user')
                user = self.db.dereference(user)
                item.update({'user': user})
                
                table = item.get('table')
                table = self.db.dereference(table)
                item.update({'table': table})
                events.append(item)
            ret.update({'lists': list(events), 'count': count, 'page': page})
            return ret
        return FormObject(form.errors)
    
    @view_config(renderer='/manage/event_create.mako', match_param='action=event_create')
    def event_create(self):
        return {}
    
    @view_config(renderer='/manage/event_edit.mako', match_param='action=event_edit')
    def event_edit(self):
        validators = dict(eventid=ObjectIdConverter())
        form = Form(self.request,validators=validators, state=State(request=self.request))
        if form.validate(force_validate=True):
            eventid = form.data.get("eventid")
            event = self.db.event.find_one({'_id': eventid, 'user.$id': self.request.user.id})
            if event:
                return dict(event=event)
            else:
                raise PageError(u'该日程不存在')
        return FormObject(form.errors)
    
    @view_config(renderer='manage/feed_list.mako', match_param=('action=feed_list'))
    def feed_list(self):
        validators = dict(
                          page=fe.validators.Int(if_missing=1, if_empty=1),
                          keyword = fe.validators.UnicodeString(if_missing="", if_empty="", strip=True),
                          starttime = fe.validators.Int(if_missing=0, if_empty=0),
                          endtime = fe.validators.Int(if_missing=0, if_empty=0),
                          iswall=fe.validators.StringBool(if_missing=False, if_empty=False)
                          )
        form = Form(self.request,validators=validators, state=State(request=self.request))
        if form.validate(force_validate=True):
            data = JSONObject(form.data)
            page = data.page
            keyword = data.keyword
            starttime = data.starttime
            endtime = data.endtime
            userid =  self.request.params.get("userid", "")
            eventid =  self.request.params.get("eventid", "")
            iswall = data.iswall
            page = page if page >0 else 1
            pageSize = 20
            
            eventids=[]
            tables = self.db.event_table.find({'user.$id': self.request.user.id})
            if tables:
                tableids = [table.get('_id') for table in tables]
                events = self.db.event.find({'table.$id': {'$in': tableids}})
                if events:
                    eventids = [event.get('_id') for event in events]
            
            ret = dict()
            if len(eventids) >0:
                condition={}    
                if ObjectId.is_valid(userid):
                    user = self.db.user.find_one({'_id': ObjectId(userid)})
                    if user:
                        condition.update({'user.$id': user.get('_id')})
                        ret.update({'user': user})
                if ObjectId.is_valid(eventid):
                    event = self.db.event.find_one({'_id': ObjectId(eventid)})
                    if event:
                        condition.update({'event.$id': event.get('_id')})
                        ret.update({'event': event})
                else:
                    condition.update({'event.$id': {'$in': eventids}})
                
                if condition != {}:
                    if keyword and len(keyword)>0:
                        condition.update({'$or': [{'content': {'$regex': ".*%s.*" % keyword, "$options": "i"}}]})
                    if starttime!=0 and endtime!=0 and starttime<endtime:
                        condition.update({'time.create': {'$gt': starttime, '$lt': endtime}})
                    elif starttime!=0:
                        condition.update({'time.create': {'$gt': starttime}})
                    elif endtime!=0:
                        condition.update({'time.create': {'$lt': endtime}})
                    
                    if iswall:
                        condition.update({'iswall': True})
                        
                    lists = self.db.feed.find(condition).sort([('time.create', DESCENDING)])
                    count = lists.count()
                    lists = lists.skip((page-1)*pageSize).limit(pageSize)
                    items = []
                    for item in lists:
                        user = item.get('user')
                        user = self.db.dereference(user)
                        item.update({'user': user})
                        event = item.get('event')
                        event = self.db.dereference(event)
                        item.update({'event': event})
                        items.append(item)
                    ret.update({'lists': list(items), 'count': count, 'page': page})
#                     return dict(lists=list(items), count=count, page=page)
            return ret
        return FormObject(form.errors)
    
    @view_config(renderer='manage/user_list.mako', match_param=('action=user_list'))
    def user_list(self):
        validators = dict(
                          page=fe.validators.Int(if_missing=1, if_empty=1),
                          keyword=fe.validators.UnicodeString(if_missing="", if_empty="", strip=True),
                          )
        form = Form(self.request,validators=validators, state=State(request=self.request))
        if form.validate(force_validate=True):
            eventid =  self.request.params.get("eventid", "")
            tid =  self.request.params.get("tid", "")
            data = JSONObject(form.data)
            page = data.page
            keyword = data.keyword
            page = page if page >0 else 1
            pageSize = 20
            
            condition = {}
            ret=dict()
            if ObjectId.is_valid(eventid):
                event = self.db.event.find_one({'_id': ObjectId(eventid)})
                if event:#日程添加者列表
                    ret.update({'event': event})
                    adds = self.db.alarm.find({'event.$id': ObjectId(eventid)},{'user': True}).sort([('time.create', DESCENDING)])
                    userids = [add['user'].id for add in adds]
                    if len(userids)>0:
                        condition.update({'_id': {'$in': userids}})
            
            if ObjectId.is_valid(tid):#日程表关注者列表
                table = self.db.event_table.find_one({'_id': ObjectId(tid)})
                if table:
                    ret.update({'table': table})
                    follows = self.db.event_table_follow.find({'table.$id': ObjectId(tid)},{'user': True}).sort([('time.create', DESCENDING)])
                    userids = [follow['user'].id for follow in follows]
                    if len(userids)>0:
                        condition.update({'_id': {'$in': userids}})
            if condition!={}:
                if keyword and len(keyword)>0:
                    condition.update({'$or': [{'name': {'$regex': ".*%s.*" % keyword, "$options": "i"}}]})
                
                lists = self.db.user.find(condition, {'password': False}).sort([('time.create', DESCENDING)])
                count = lists.count()
                lists = lists.skip((page-1)*pageSize).limit(pageSize)
                items = []
                for item in lists:
                    items.append(item)
                ret.update({'lists':list(items), 'count': count, 'page':page})
            return ret
#             return dict(lists=list(items), count=count, page=page)
        return FormObject(form.errors)

@view_defaults(route_name='api', permission='user')
class APIView(object):
    """后端调用json接口"""
    def __init__(self, request):
        self.request = request
        self.db = request.db
    
    @view_config(renderer='jsonp', match_param=('action=qiniu_uptoken'))
    def qiniu_uptoken(self):
        token= QiniuClient().get_token()
        return dict(token=token,uptoken=token)
    
    @view_config(renderer='jsonp', match_param=('action=table_create'))
    def table_create(self):
        """ 主题创建 """
        validators = dict(
                          title = fe.validators.UnicodeString(min=1, max=40, strip=True),
                          content = fe.validators.UnicodeString(max=400, strip=True, if_missing=None, if_empty=None),
                          headimg = fe.validators.UnicodeString(max=255, strip=True, if_missing=None, if_empty=None),
                          largeimg = fe.validators.UnicodeString(max=255, strip=True, if_missing=None, if_empty=None),
                          privacy = fe.Pipe(fe.validators.Int(), fe.validators.OneOf([0,1])),
                          mode = fe.Pipe(fe.validators.Int(), fe.validators.OneOf([0,1])),
                          )
        form = Form(self.request,validators=validators, state=State(request=self.request))
        if form.validate(force_validate=True):
            title = form.data.get('title')
            content = form.data.get('content')
            headimg = form.data.get('headimg')
            largeimg = form.data.get('largeimg')
            privacy = form.data.get('privacy')
            mode = form.data.get('mode')
            table = {
                     'user': DBRef('user', self.request.user.id),
                     'title': title,
                     'privacy': privacy,
                     'time': {'update': int(time.time()*1000)},
                     'isdeleted': False,
                     'recommend': 0,
                     'mode': mode,
                     }
            if content:
                table.update({'content': content})
            if headimg:
                table.update({'headimg': headimg})
            if largeimg:
                table.update({'largeimg': largeimg})
            self.db.event_table.save(table)
            
            #创建专题之后立刻关注
            self.db.event_table.update({'_id': table.get("_id")}, {'$inc': {'stat.follow': 1}})
            follow = {
                      'user': DBRef('user', self.request.user.id),
                      'table': DBRef('event_table', table.get("_id")),
                      'time': {'create': int(time.time()*1000)}
                      }
            self.db.event_table_follow.save(follow)
            return dict(result=1)
#             table.update({'user': user_snap(self.request.user)})
#             return table
        return FormObject(form.errors)
    
    @view_config(renderer='jsonp', match_param=('action=table_edit'))
    def table_edit(self):
        """ 主题编辑 """
        validators = dict(
                          id=ObjectIdConverter(),
                          title = fe.validators.UnicodeString(min=1, max=40, strip=True),
                          content = fe.validators.UnicodeString(if_missing=None, if_empty=None),     
                          )
        form = Form(self.request,validators=validators, state=State(request=self.request))
        if form.validate(force_validate=True):
            id = form.data.get("id")
            title = form.data.get("title")
            content = form.data.get("content")
            table = self.db.event_table.find_one({'_id': id})
            if table:
                table_value={}
                if table.get('title')!=title:
                    table_value.update({'title': title})
                if content and table.get('content', '')!=content:
                    table_value.update({'content': content})
                if table_value!={}:
                    self.db.event_table.update({'_id': id},{'$set': table_value})
                return dict(result=1)
            else:
                raise APIError(-1, u'该活动不存在', path=self.request.path)
        return FormObject(form.errors)
    
    @view_config(renderer='jsonp', match_param=('action=set_event_table_mode'))
    def set_event_table_mode(self):
        validators = dict(
                          tid=ObjectIdConverter(),
                          mode = fe.Pipe(fe.validators.Int(if_missing=-1, if_empty=-1), fe.validators.OneOf([-1,0,1]))
                          )
        form = Form(self.request,validators=validators, state=State(request=self.request))
        if form.validate(force_validate=True):
            tid = form.data.get('tid')
            mode = form.data.get('mode')
            if mode==-1:
                raise APIError(-1, u'非法的操纵', path=self.request.path)
            table = self.db.event_table.find_one({'_id': tid, 'user.$id': self.request.user.id})
            if table and table.get('mode')!=mode:
                self.db.event_table.update({'_id': tid}, {'$set': {'mode': mode}})
            return dict(result=1)
        return FormObject(form.errors)
    
    @view_config(renderer='jsonp', match_param=('action=set_event_table_privacy'))
    def set_event_table_privacy(self):
        validators = dict(
                          tid=ObjectIdConverter(),
                          privacy = fe.Pipe(fe.validators.Int(if_missing=-1, if_empty=-1), fe.validators.OneOf([-1,0,1]))
                          )
        form = Form(self.request,validators=validators, state=State(request=self.request))
        if form.validate(force_validate=True):
            tid = form.data.get('tid')
            privacy = form.data.get('privacy')
            if privacy==-1:
                raise APIError(-1, u'非法的操纵', path=self.request.path)
            table = self.db.event_table.find_one({'_id': tid, 'user.$id': self.request.user.id})
            if table and table.get('privacy')!=privacy:
                self.db.event_table.update({'_id': tid}, {'$set': {'privacy': privacy}})
            return dict(result=1)
        return FormObject(form.errors)
    
    @view_config(renderer='jsonp', match_param=('action=event_create'))
    def event_create(self):
        ''' 活动发布接口 '''
        validators = dict(
                          tableid = ObjectIdConverter(),
                          alarm=Alarm(if_missing=None, if_empty=None),
                          title = fe.validators.UnicodeString(min=1, strip=True),
                          content = fe.validators.UnicodeString(strip=True, if_missing=None, if_empty=None),
                          addr = fe.validators.UnicodeString(max=30, strip=True, if_missing=None, if_empty=None),
                          )
        form = Form(self.request,validators=validators,state=State(request=self.request), variable_decode=True)
        if form.validate(force_validate=True):
            event = JSONObject()
            form.bind(event)
            tableid = event.pop('tableid')
            table = self.db.event_table.find_and_modify({'_id': tableid, '$or': [
                                                                                 {'mode': 1}, 
                                                                                 {'user.$id': self.request.user.id}
                                                                                 ]
                                                         }, {
                                                             '$inc': {'stat.event': 1}
                                                             })
            if not table:
                raise APIError(-1, u'不能向该日程表里添加日程', path= self.request.path)
            
            #添加活动时，若尚未关注该专题，则需先添加关注
            follow = self.db.event_table_follow.find_one({'table.$id': tableid, 'user.$id': self.request.user.id})
            if not follow:
                self.db.event_table.update({'_id': tableid}, {'$inc': {'stat.follow': 1}})
                follow = {
                          'user': DBRef('user', self.request.user.id),
                          'table': DBRef('event_table', tableid),
                          'time': {'create': int(time.time()*1000)}
                          }
                self.db.event_table_follow.save(follow)
            
            alarm = event.get('alarm')
            if not alarm:
                event.pop('alarm')
            addr = event.get('addr')
            if not addr:
                event.pop('addr')
            event.update({"isdeleted": False, "enable": True})
            event.update({"time": {"create": int(time.time()*1000)}})
            event.update({"user": DBRef('user', self.request.user.id)})
            event.update({"stat": {"add": 1, "feed": 0}})
            event.update({'table': DBRef('event_table', tableid)})
            self.db.event.save(event)
            
            #设置个性化报警信息
            if not alarm:
                alarm = {}
            else:
                alarm = alarm.copy()
            alarm.update({'user': DBRef('user', self.request.user.id)})
            alarm.update({'event': DBRef('event', event.get("_id"))})
            alarm.update({'status': 10, 'isroot': True})
            alarm.update({'time': {'create': int(time.time()*1000)}})
            alarm.update({'privacy': 1})
            self.db.alarm.save(alarm)
#             event.update({'user': user_snap(self.request.user)})
#             alarm.update({'event': event})
#             return dict(alarm = alarm)
            return dict(result=1)
        return FormObject(form.errors)
    
    @view_config(renderer='jsonp', match_param=('action=event_edit'))
    def event_edit(self):
        '''活动编辑'''
        validators = dict(
                          id=ObjectIdConverter(),
                          title = fe.validators.UnicodeString(max=40, strip=True, if_missing=None, if_empty=None),
                          content = fe.validators.UnicodeString(strip=True, if_missing=None, if_empty=None),
                          alarm=Alarm(if_missing=None, if_empty=None),
                          addr = fe.validators.UnicodeString(max=30, strip=True, if_missing=None, if_empty=None),
#                           push = fe.validators.StringBool()
                          )
        form = Form(self.request,validators=validators,state=State(request=self.request), variable_decode=True)
        if form.validate(force_validate=True):
            id = form.data.get("id")
            title = form.data.get('title')
            content = form.data.get('content')
            alarm = form.data.get("alarm")
            addr = form.data.get('addr')
#             push = form.data.get('push')
            
            event = self.db.event.find_one({'_id': id, 'user.$id': self.request.user.id})
            if event:
                event_value = {'time.update': int(time.time()*1000), 'enable': True}
                alarm_value = {'time.update': int(time.time()*1000)}
                if alarm is not None:
                    event_value.update({'alarm': alarm})
                    alarm_value.update(alarm)
                if addr:
                    event_value.update({'addr': addr})
                if title:
                    event_value.update({'title': title})
                if content:
                    event_value.update({'content': content})
                
                self.db.alarm.update({'event.$id': event.get('_id'), 'status': 10}, {'$set': alarm_value}, multi=True)
                self.db.event.update({'_id': event.get('_id')}, {'$set': event_value})
                
# #                 推送活动变更消息
#                 if push:
#                     alarms = self.db.alarm.find({'event.$id': event.get('_id'), 'status': 10, 'isroot': False})
#                     for alarm in alarms:
#                         user = alarm.get('user')
#                         self.push_change(user.id, event)
            return dict(result=1)
        return FormObject(form.errors)
    
    @view_config(renderer='jsonp', match_param=('action=set_feed_wall'))
    def set_feed_wall(self):
        '''活动记录上墙'''
        validators = dict(
                          feedid=ObjectIdConverter(),
                          iswall=fe.validators.StringBool(if_missing=False, if_empty=False)
                          )
        form = Form(self.request,validators=validators, state=State(request=self.request))
        if form.validate(force_validate=True):
            feedid = form.data.get('feedid')
            iswall = form.data.get('iswall')
            feed = self.db.feed.find_one({'_id': feedid})
            if feed and feed.get('iswall')!=iswall:
                self.db.feed.update({'_id': feedid}, {'$set': {'iswall': iswall}})
            return dict(result=1)
        return FormObject(form.errors)
    
    @view_config(renderer='jsonp', match_param=('action=wall_feeds'), permission=None)
    def wall_feeds(self):
        validators = dict(
                          eventid=ObjectIdConverter()
                          )
        form = Form(self.request,validators=validators, state=State(request=self.request))
        if form.validate(force_validate=True):
            eventid = form.data.get('eventid')
            event = self.db.event.find_one({'_id': eventid})
            if event:
                items = []
                lists = self.db.feed.find({'event.$id': eventid,'iswall': True}).sort([('time.create', DESCENDING)])
                
                for item in lists:
                    user = item.get('user')
                    user = self.db.dereference(user)
                    item.update({'user': user_snap(user)})
                    items.append(item)
                return items
            raise APIError(-1, u'你所找的活动不存在', path=self.request.path)
        return FormObject(form.errors)
    
    @view_config(renderer='jsonp', match_param=('action=wall_users'), permission=None)
    def wall_users(self):
        validators = dict(
                          eventid=ObjectIdConverter()
                          )
        form = Form(self.request,validators=validators, state=State(request=self.request))
        if form.validate(force_validate=True):
            eventid = form.data.get('eventid')
            event = self.db.event.find_one({'_id': eventid})
            if event:
                items = []
                userids = []
                lists = self.db.feed.find({'event.$id': eventid}).sort([('time.create', DESCENDING)])
                
                for item in lists:
                    user = item.get('user')
                    if user.id in userids:
                        continue
                    userids.append(user.id)                    
                    user = self.db.dereference(user)
                    items.append(user_snap(user))
                return items
            raise APIError(-1, u'你所找的活动不存在', path=self.request.path)
        return FormObject(form.errors)
    
    @view_config(renderer='jsonp', match_param=('action=event_table_list'))
    def event_table_list(self):
        tables = self.db.event_table.find({'user.$id': self.request.user.id})
        count = tables.count()
        tables = list(tables)
        items = []
        if count >0:
            for item in tables:
                items.append((item.get('_id'), item.get('title')))
        return items
    
@view_defaults(route_name='proxy')
class Proxy(object):
     
    def __init__(self, request):
        self.request = request
        self.db = self.request.db
        userid = str(request.user.id)
        expire_in = int(time.time() + 3600*24*356)
        t = Token()
        self.access_token = t.encode(userid, expire_in)
        self.api_url = request.registry.settings['api_uri']
         
    @view_config(renderer='jsonp', match_param=('action=event_create'))
    def event_create(self):
        params = {
                  'title': 'title',
                  'addr': 'addr',
                  'tableid': '5486f0091d41c8154fda6a9c'
                  }
#         params.update(self.request.params)
        params.update({'access_token': self.access_token})
        r = requests.post(self.api_url + '/event/create', params)
        return r.json()
    
    @view_config(renderer='jsonp', match_param=('action=event_edit'))
    def event_edit(self):
        params = {
                  'id':'54310c15fbe78e4e6310a553',
#                   'userids-0':'54890f6c1d41c820b34a6834',
#                   'userids-1':'545ffea3fbe78e7bbeb95b15'
                  }
#         params.update(self.request.params)
        params.update({'access_token': self.access_token})
#         print params
        r = requests.post(self.api_url + '/event/change_users_in_msggroup', params)
        return r.json()
    
class QiniuClient(object):
    def __init__(self):
        qiniu.conf.ACCESS_KEY = "TUo-Zhi8ICQGKqHVuIzL1rYdb5itNEF4F6fQzJjr"
        qiniu.conf.SECRET_KEY = "n0pp6ksP4TNEWZaVGfV4B6jLJIRkIt9G44Vk3R9R"
        #qiniu.rs.PutPolicy.callbackUrl='/manage/qiniu_callback'
        #qiniu.rs.PutPolicy.callbackBody="name=$(fname)&url=$(etag)"
        self.bucket_domain="http://shikeapp.qiniudn.com/"
        self.bucket_name="shikeapp"
    
    def get_token(self):
        policy = qiniu.rs.PutPolicy(self.bucket_name)
        token= policy.token()
        return token
#     def put_file(self):
#         uptoken = self.get_token()
#         localfile = "%s" % __file__
#         import qiniu.resumable_io as rio        
#                
#         extra = rio.PutExtra(self.bucket_name)
#                 
#         ret, err = rio.put_file(uptoken, key, localfile, extra)
#         if err is not None:
#             sys.stderr.write('error: %s ' % err)
#             return
#         print ret