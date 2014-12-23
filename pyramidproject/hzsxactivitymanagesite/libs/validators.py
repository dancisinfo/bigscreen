#coding=utf-8
import formencode as fe
import re
from bson.objectid import ObjectId

_ = lambda s: s


class PhoneNumber(fe.FancyValidator):
    
    def _convert_to_python(self, value, state):
        validator = fe.validators.Regex(r'^(13|15|18|17|14)\d{9}$')
        value = validator.to_python(value, state)
        return value
    
    _to_python = _convert_to_python
    
    

class ImageUploader(fe.FancyValidator):
    
    messages = dict(
                    imageExt = _(u'文件类型必须是图片，后缀为.jpg|.png之一')
                    )
    
    def _convert_to_python(self, value, state):
        validator = fe.validators.FieldStorageUploadConverter()
        value = validator.to_python(value, state)
        return value
    
    def _validate_python(self, value, state):
        pattern = re.compile(r'^(jpg|png|JPG|PNG)$')
        ext = value.filename.split('.')[-1:][0]
        if not pattern.match(ext):
            msg = self.message('imageExt', state, object=value)
            raise fe.Invalid(msg, value, state)
    
    _to_python = _convert_to_python
    validate_python = _validate_python

class AudioUploaderConverter(fe.FancyValidator):
    
    messages = dict(
                    audioExt = _(u'文件类型必须是音频文件，后缀为.mp3|.amr之一')
                    )
    
    def _convert_to_python(self, value, state):
        validator = fe.validators.FieldStorageUploadConverter()
        value = validator.to_python(value, state)
        return value
    
    def _validate_python(self, value, state):
        pattern = re.compile(r'^(amr|mp3|AMR|MP3)$')
        ext = value.filename.split('.')[-1:][0]
        if not pattern.match(ext):
            msg = self.message('audioExt', state, object=value)
            raise fe.Invalid(msg, value, state)
    
    _to_python = _convert_to_python
    validate_python = _validate_python


class ObjectIdConverter(fe.FancyValidator):
    
    messages = dict(
                    invalid = _('Invalid value')
                    )
    
    def _convert_to_python(self, value, state):
        if value is None or not ObjectId.is_valid(value):
            msg = self.message('invalid', state, object=value)
            raise fe.Invalid(msg, value, state)
        return ObjectId(value)
    
    _to_python = _convert_to_python