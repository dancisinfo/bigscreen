#coding=utf-8
from pyramid.security import Allow
from logging import getLogger

log = getLogger(__name__)

class JSONObject(dict):
    
    def __init__(self, a_dict={}):
        super(JSONObject, self).__init__(self)
        self.update(a_dict)
    
    def __getattr__(self, name):
        return self[name]

    
    def __setattr__(self, name, value):
        self.update({name:value})

class FormObject(JSONObject):
    
    def __init__(self, form_errors):
        super(FormObject,self).__init__({})
        if form_errors:
            self.error_code = 10006
            self.form_errors = form_errors
            self.error = '\n'.join('%s: %s' % err for err in form_errors.items()) 
        

class User(JSONObject):
    @property
    def __acl__(self):
        return [
            (Allow, str(self.id), 'edit'),
        ]
    
    def __init__(self, a_dict):
        super(User,self).__init__(a_dict)
        self.id = a_dict['_id']
        self.__name__ = None
        self.__parent__ = None
        

    