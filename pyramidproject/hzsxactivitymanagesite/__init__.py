from pyramid.config import Configurator
from pyramid.authorization import ACLAuthorizationPolicy
from pyramid.security import unauthenticated_userid
from pyramid.events import NewRequest
from pyramid.renderers import JSONP

import pymongo, datetime, sys, redis

from bson.objectid import ObjectId
from bson.dbref import DBRef
from urlparse import urlparse
from logging import getLogger

from .resources import User
from .authentication import AuthenticationPolicy

reload(sys)
sys.setdefaultencoding('utf-8')

log = getLogger(__name__)

def get_user(request):
    userid = unauthenticated_userid(request)
    if userid is not  None and ObjectId.is_valid(userid):
        user = request.db.user.find_one({'_id': ObjectId(userid)})
        if user and user.get('status') == 2:
            return User(user)

def get_db(request):
    settings = request.registry.settings
    db_url = urlparse(settings['mongo_uri'])
    conn = pymongo.MongoClient(host=db_url.hostname, port=db_url.port)
    db = conn[db_url.path[1:]]
    if db_url.username and db_url.password:
        db.authenticate(db_url.username, db_url.password)
    return db

def get_fs(request):
    fs = GridFS(request.db)
    return fs

def objectid_adapter(obj, request):
    return str(obj)

def dbref_adapter(obj, request):
    return {'$id': obj.id}

def datetime_adapter(obj, request):
    return obj.isoformat()

def real_ip_hook(event):
    if 'HTTP_X_REAL_IP' in event.request.environ:
        event.request.environ['REMOTE_ADDR'] = event.request.environ['HTTP_X_REAL_IP']
    if 'http_host' in event.request.registry.settings:
        event.request.environ['HTTP_HOST'] = event.request.registry.settings['http_host']

def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    authentication_policy = AuthenticationPolicy(
        settings['auth.secret'], cookie_name='shike.im')
    authorization_policy = ACLAuthorizationPolicy() 
    config = Configurator(settings=settings)
    config.set_root_factory('hzsxactivitymanagesite.resources.RootFactory')
    config.set_authentication_policy(authentication_policy)
    config.set_authorization_policy(authorization_policy)
    
    jsonp = JSONP(param_name='callback')
    jsonp.add_adapter(ObjectId, objectid_adapter)
    jsonp.add_adapter(DBRef, dbref_adapter)
    jsonp.add_adapter(datetime.datetime, datetime_adapter)
    config.add_renderer('jsonp', jsonp)
    config.add_subscriber(real_ip_hook, NewRequest)
    config.set_request_property(get_db, "db", reify=True)
    config.set_request_property(get_fs, "fs", reify=True)
    config.set_request_property(get_user, "user", reify=True)
    
    config.add_static_view('static', 'static', cache_max_age=3600)
    config.include("hzsxactivitymanagesite.views.home")
    config.add_forbidden_view("hzsxactivitymanagesite.views.forbidden_view",  renderer="json")
    config.add_notfound_view("hzsxactivitymanagesite.views.notfound_view", renderer="json")
    config.add_view("hzsxactivitymanagesite.views.apierror_view", context='hzsxactivitymanagesite.exceptions.APIError', renderer='json')
    config.add_view("hzsxactivitymanagesite.views.pageerror_view", context='hzsxactivitymanagesite.exceptions.PageError', renderer='error.mako')
    return config.make_wsgi_app()
