<%inherit file="mako_template.mako" />
<div class="btn-group ">
  <a href="/manage/home"><button class="btn btn-reverse">返回专题列表</button></a>
</div>
<div class="widget">
    <div class="widget-header">
       <h3>创建专题</h3>
    </div>
    <div class="widget-content">
    %if result and result==1:
      <h1 style="text-align:center;margin-top:200px;">创建成功!</h1>
      <script type="text/javascript">
        setTimeout(function(){
          window.location.href="/manage/home";
        },2000);
      </script>
    %elif error:
      <h1 style="text-align:center;margin-top:100px;">
        <p>表单参数错误</p>
        %for x in form_errors:
          <p>${form_errors[x]}</p>
        %endfor
      </h1>
    %else:
        <form class="form-horizontal" role="form" id="table_form">
            <fieldset>
              <div class="control-group">
                <label class="control-label" for="title"><i class="help-important">*</i>频道名称</label>
                <div class="controls">
                  <input type="text" value="" class="form-control" autofocus="on" maxlength="40" autocomplete="on" id="title" name="title">
                  <p class="help-block"></p>
                </div>
              </div>
              <div class="control-group">
                <label class="control-label" for="title"><i class="help-important">*</i>是否频道公开</label>
                <div class="controls">
                	<label class="radio"><input type="radio" name="privacy" value="1" checked />所有人可见</label> 
                	<label class="radio"><input type="radio" name="privacy" value="0" />仅自己可见</label>
                	<p class="help-block"></p>
                </div>
              </div>
              <div class="control-group">
                <label class="control-label" for="title"><i class="help-important">*</i>上传频道封面</label>
                <div class="controls">
                	<div id="qiniu_container"><a class="btn btn-default btn-lg " id="pickfiles" href="javascript:void(0)" >上传封面图片</a></div>
					<div id="preview_box">
						<img src="" id="preview_img" alt="封面图片" />
						<input name="qiniu-src" type="hidden" value="" />
					</div>
					<p class="help-block">建议图片尺寸为400pxx300px,只支持jpg,png,jpeg格式</p>
                </div>
              </div>
              <div class="control-group">
                <label class="control-label" for="title"><i class="help-important">*</i>是否允许他人新建日程</label>
                <div class="controls">
                	<label class="radio"><input type="radio" name="mode" value="1" checked />是</label>
					<label class="radio"><input type="radio" name="mode" value="0" />否</label>                  
                	<p class="help-block"></p>
                </div>
              </div>
              <div class="control-group">
                <label class="control-label  " for="content">专题内容</label>
                <div class=" controls">
                 <textarea name='content' class="form-control" style="min-height:100px;height:100%"></textarea>
                  <p class="help-block"></p>
                </div>
              </div>
              <div class="control-group ">
                <label class="control-label">&nbsp;</label>
                <div class="controls">
                  <span id="submit-btn" class="btn btn-primary">创建</span>
                  <span id="cancel-btn" class="btn btn-success">取消</span>
                </div>
              </div>
              <div class="control-group ">
                <label class="control-label">&nbsp;</label>
                <div class="controls help-errors">
                </div>
              </div>
            </fieldset>
          </form>
      %endif
    </div>
    <div>
</div>
</div>
</div>
<!--
<script type="text/javascript" src="/static/qiniu_upload/plupload/plupload.full.min.js"></script>-->
<script type="text/javascript" src="/static/qiniu_upload/plupload/moxie.min.js"></script>
<script type="text/javascript" src="/static/qiniu_upload/plupload/plupload.dev.js"></script>
<script type="text/javascript" src="/static/qiniu_upload/qiniu.min.js"></script>
<script type="text/javascript" src="/static/js/qiniu_upload.config.js"></script>


<script type="text/javascript" src="/static/js/manage.js"></script>
<script type="text/javascript">
$(function(){
  $("#submit-btn").click(function(){
    var senddata={
      'title':$("#title").val(),
      'content':$("textarea[name=content]").val(),
      'privacy':$('input[name=privacy]:checked').val(),
      'mode':$('input[name=mode]:checked').val(),
    };
    var imageurl = $("input[name=qiniu-src]").val();
	if(imageurl!=undefined && imageurl!=""){
		senddata.headimg = imageurl+'-head';
		senddata.largeimg = imageurl+'-large';
	}
    if(!senddata) return;
    $.ajax({
      url: "/api/table_create",
      data: senddata,
      type: "post",
      dataType: "jsonp",
      success: function(data){
        if(data.form_errors){
          dispatchError(data.form_errors);
        }
        else{
          successReturn("${request.route_url('manage', action='home')}");
        }
      },
      error: function(data){
        alert("网络错误，请联系管理员");
      }
    });
  });
});
</script>