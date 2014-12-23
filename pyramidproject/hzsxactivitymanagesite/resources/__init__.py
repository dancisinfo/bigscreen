#coding=utf-8
from pyramid.security import Allow, Everyone, Authenticated, ALL_PERMISSIONS
from hzsxactivitymanagesite.resources.models import *
from bson.objectid import ObjectId
from logging import getLogger

log = getLogger(__name__)

def _assign(obj, name, parent):
    obj.__name__ = name
    obj.__parent__ = parent
    return obj

class RootFactory(object):
    __acl__ = [
        (Allow, Authenticated, 'user'),
        (Allow, 'g:admin', ALL_PERMISSIONS),
    ]
    
    def __init__(self, request):
        self.request = request

