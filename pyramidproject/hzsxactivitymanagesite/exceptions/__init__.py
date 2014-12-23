#coding=utf-8
class APIError(StandardError):
    '''
    raise APIError if got failed json message.
    '''
    def __init__(self, error_code, error, path=None):
        self.error_code = error_code
        self.error = error
        self.path = path
        StandardError.__init__(self, error)

    def __str__(self):
        return 'APIError: %s: %s, request: %s' % (self.error_code, self.error, self.path)

class PageError(StandardError):
    def __init__(self, error, path):
        self.error = error
        self.path = path
        StandardError.__init__(self, error)

    def __str__(self):
        return 'PageError: %s, request: %s' % (self.error, self.path)   
    
