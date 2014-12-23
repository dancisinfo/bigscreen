#coding=utf-8
from hzsxactivitymanagesite.libs.validators import *
import datetime
from PIL import Image
import io
from logging import getLogger

log = getLogger(__name__)

_ = lambda s: s




def Password(*kw, **kwargs):
    return fe.validators.String(min=6, max=20, *kw, **kwargs)

def PhoneCode(*kw, **kwargs):
    return fe.validators.String(min=4, max=6, strip=True)


class AudioUploader(fe.FancyValidator):
    
    def _convert_to_python(self, value, state):
        if isinstance(value, str):
            return value.strip()
        validator = AudioUploaderConverter()
        value = validator.to_python(value, state)
        id = state.request.fs.put(value.file.read(), content_type='audio/3gpp', filename='audio.amr')
        url = state.request.route_url('res', type='file', _query=dict(fid=id)) 
        return url
    _to_python = _convert_to_python

class Photo(fe.FancyValidator):
    width_large=1024
    width_thumbnail=240
    
    messages = dict(
                    invalid = _(u'非法的图片'),
                    toosmall = _(u'图片太小了，图片长宽需大于%dpx' % width_thumbnail),
                    ioerror = _(u'服务器暂时不支持该图片类型'),
                    memoryerror = _(u'图像处理错误')
                    )
    def _convert_to_python(self, value, state):
        img = Image.open(value)
        if img:
            try:
                region = img.size
                if region[0] < self.width_thumbnail or region[1] < self.width_thumbnail:
                    msg = self.message('toosmall', state, object=value)
                    raise fe.Invalid(msg, value, state)
                
                scale = float(region[1]) / region[0]
                if region[0]>self.width_large:
                    region = (self.width_large, int(self.width_large*scale))
                    img.thumbnail(region, Image.ANTIALIAS)
                    
                content = io.BytesIO()
                img.save(content,'JPEG')
                id_large = state.request.fs.put(content.getvalue(), content_type='image/jpeg', filename='large_%dX%d.jpg' % region)
                
                region = (self.width_thumbnail, int(self.width_thumbnail*scale))
                img.thumbnail(region, Image.ANTIALIAS)
                content = io.BytesIO()
                img.save(content,'JPEG')
                id_thumbnail = state.request.fs.put(content.getvalue(), content_type='image/jpeg', filename='thumbnail_%dX%d.jpg' % region)
                
                url_thumbnail = state.request.route_url('res', type='image', _query=dict(fid=id_thumbnail))
                url_large = state.request.route_url('res', type='image', _query=dict(fid=id_large))
                return {'thumbnail': url_thumbnail, 'large': url_large}
            except IOError, e:
                msg = self.message('ioerror', state, object=value)
                raise fe.Invalid(msg, value, state)
            except MemoryError, e:
                msg = self.message('memoryerror', state, object=value)
                raise fe.Invalid(msg, value, state)
        else:
            msg = self.message('invalid', state, object=value)
            raise fe.Invalid(msg, value, state)
        
    _to_python = _convert_to_python
    
class PhotoUploader(fe.FancyValidator):
    
    def _convert_to_python(self, value, state):
        if isinstance(value, dict):
            return {'thumbnail': value.get('thumbnail'), 'large': value.get('large')}
        validator = ImageUploader()
        value = validator.to_python(value, state)
        validator = Photo()
        photo = validator.to_python(value.file, state)
        return photo
    
    _to_python = _convert_to_python

class MultiPhotoUploader(fe.FancyValidator):
    
    max_count = 9
    
    messages = dict(
                    invalid = _('Invalid value'),
                    count = _(u'上传照片数量不能多于%d' % max_count),
                    )
    
    def _convert_to_python(self, value, state):
        if isinstance(value, list):
            if len(value) > self.max_count:
                msg = self.message('count', state, object=value)
                raise fe.Invalid(msg, value, state)
            photos = []
            validator = PhotoUploader()
            for item in value:
                photo = validator.to_python(item, state)
                if photo:
                    photos.append(photo)
            return photos
        else:
            msg = self.message('invalid', state, object=value)
            raise fe.Invalid(msg, value, state)
    
    _to_python = _convert_to_python

class Avatar(fe.FancyValidator):
    width_large=1024
    width_head=132
    
    messages = dict(
                    invalid = _(u'非法的图片'),
                    toosmall = _(u'图片太小了，图片长宽需大于%dpx' % width_head),
                    ioerror = _(u'服务器暂时不支持该图片类型'),
                    memoryerror = _(u'图像处理错误')
                    )
    def _convert_to_python(self, value, state):
        img = Image.open(value)
        if img:
            try:
                region = img.size
                if region[0] < self.width_head or region[1] < self.width_head:
                    msg = self.message('toosmall', state, object=value)
                    raise fe.Invalid(msg, value, state)
                
                scale = float(region[1]) / region[0]
                if region[0]>self.width_large:
                    region = (self.width_large, int(self.width_large*scale))
                    img.thumbnail(region, Image.ANTIALIAS)
                    
                content = io.BytesIO()
                img.save(content,'JPEG')
                id_large = state.request.fs.put(content.getvalue(), content_type='image/jpeg', filename='large_%dX%d.jpg' % region)
                
                #高>宽
                if scale>1:
                    box = (0, (region[1] - region[0])/2, region[0], (region[1] - region[0])/2 + region[0])
                else:
                    box = ((region[0] - region[1])/2, 0, (region[0] - region[1])/2 + region[1], region[1])
                img = img.crop(box)
                region = (self.width_head, self.width_head)
                img.thumbnail(region, Image.ANTIALIAS)
                content = io.BytesIO()
                img.save(content,'JPEG')
                id_head = state.request.fs.put(content.getvalue(), content_type='image/jpeg', filename='head_%dX%d.jpg' % region)
                
                url_head = state.request.route_url('res', type='image', _query=dict(fid=id_head))
                url_large = state.request.route_url('res', type='image', _query=dict(fid=id_large))
                return {'head': url_head, 'large': url_large}
            except IOError, e:
                msg = self.message('ioerror', state, object=value)
                raise fe.Invalid(msg, value, state)
            except MemoryError, e:
                msg = self.message('memoryerror', state, object=value)
                raise fe.Invalid(msg, value, state)
        else:
            msg = self.message('invalid', state, object=value)
            raise fe.Invalid(msg, value, state)
        
    _to_python = _convert_to_python
            
            

class AvatarUploader(fe.FancyValidator):
    
    def _convert_to_python(self, value, state):
        if isinstance(value, dict):
            return {'head': value.get('head'), 'large': value.get('large')}
        validator = ImageUploader()
        value = validator.to_python(value, state)
        validator = Avatar()
        avatar = validator.to_python(value.file, state)
        return avatar
    
    _to_python = _convert_to_python



class Alarm(fe.FancyValidator):
    
    messages = dict(
                    invalid = _('Invalid value')
                    )
    
    def _convert_to_python(self, value, state):
        if isinstance(value, dict):
            dc = fe.validators.DictConverter(value)
            starttime = dc.to_python('starttime')
            period = dc.to_python('period')
            earlier = dc.to_python('earlier')
            validator = fe.validators.Int(if_empty=0)
            starttime = validator.to_python(starttime)
            period = validator.to_python(period)
            earlier = validator.to_python(earlier)
            validator = fe.validators.OneOf([0,1,2,3,4,5])
            period = validator.to_python(period)
            return dict(starttime=starttime, period = period, earlier = earlier)
        else:
            return None
    
    _to_python = _convert_to_python

class MultiObjectId(fe.FancyValidator):
    
    messages = dict(
                    invalid = _('Invalid value'),
                    )
    
    def _convert_to_python(self, value, state):
        if isinstance(value, list):
            objectIds = []
            validator = ObjectIdConverter()
            for item in value:
                objectId = validator.to_python(item, state)
                if objectId:
                    objectIds.append(objectId)
            return objectIds
        else:
            msg = self.message('invalid', state, object=value)
            raise fe.Invalid(msg, value, state)
    
    _to_python = _convert_to_python
