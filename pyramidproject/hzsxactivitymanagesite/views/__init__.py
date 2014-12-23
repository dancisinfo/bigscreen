#coding=utf-8
from hzsxactivitymanagesite.exceptions import APIError

def forbidden_view(request):
    return dict(error_code=10004,error=u'无访问权限')

def notfound_view(request):
    return dict(error_code=10005,error=u'接口无法访问')


def apierror_view(context, request):
    return dict(error_code=context.error_code,error=context.error)

def pageerror_view(context, request):
    return dict(error=context.error)