#coding=utf-8
from hzsxactivitymanagesite.resources.models import JSONObject

def user_snap(user):
    user = JSONObject(user)
    luser = {'_id': user._id, 'name': user.name, 'headimg': user.headimg, 'type': user.get('type', 0), 'is_verified': False}
    if user.has_key('gender'):
        luser.update({'gender': user.get('gender')})
    if user.has_key('verify'):
        luser.update({'is_verified': True})
    return luser