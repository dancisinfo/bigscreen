<%inherit file="mako_template.mako" />
<div class="btn-group ">
  <a href="/manage/home"><button class="btn btn-reverse">返回专题列表</button></a>
</div>
<div class="widget">
    <div class="widget-header">
       <h3>修改专题</h3>
    </div>
    <div class="widget-content">
    %if result and result==1:
      <h1 style="text-align:center;margin-top:200px;">修改成功!</h1>
      <script type="text/javascript">
        setTimeout(function(){
          window.location.href="/manage/home";
        },2000);
      </script>
    %elif error:
      <h1 style="text-align:center;margin-top:100px;">
        <p>表单输入参数错误</p>
        %for x in form_errors:
          <p>${form_errors[x]}</p>
        %endfor
      </h1>
    %elif table:
        <form class="form-horizontal" role="form" id="table_form">
            <fieldset>
              <div class="control-group">
                <label class="control-label" for="title"><i class="help-important">*</i>专题名称</label>
                <div class="controls">
                  <input type="text" value="${table.get('title','请输入专题标题')}" class="form-control" autofocus="on" maxlength="40" autocomplete="on" id="title" name="title">
                  <p class="help-block">标题长度不超过40字</p>
                </div>
              </div>
              <div class="control-group">
                <label class="control-label  " for="content">专题内容</label>
                <div class=" controls">
                  <textarea name='content' class="form-control" style="min-height:100px;height:100%">${table.get('content','')}</textarea>
                </div>
              </div>
              <div class="control-group ">
                <label class="control-label">&nbsp;</label>
                <div class="controls">
                  <span id="submit-btn" class="btn btn-primary">保存</span>
                  <a class="btn btn-success" href="/manage/home">返回列表</a>
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
<!--七牛-->
<!--
<script type="text/javascript" src="/static/qiniu_upload/plupload/plupload.full.min.js"></script> 
<script type="text/javascript" src="/static/qiniu_upload/plupload/moxie.min.js"></script>
<script type="text/javascript" src="/static/qiniu_upload/plupload/plupload.dev.js"></script>
<script type="text/javascript" src="/static/qiniu_upload/qiniu.min.js"></script>
-->

<script type="text/javascript" src="/static/js/manage.js"></script>
<script type="text/javascript">
  //var ue=UE.getEditor('myEditor');
  $("#submit-btn").click(function(){
    var senddata={
      id:'${request.params.get("tid")}',
      title:$("#title").val(),
      content:$("textarea[name=content]").val()
    };
    if(!senddata) return;
    $.ajax({
      url: "/api/table_edit",
      data: senddata,
      type:"post",
      dataType: "jsonp",
      success: function(data){
        if(data.form_errors){
          dispatchError(data.form_errors);
        }
        else{
          successReturn("${request.route_url('manage', action='home')}");
        }
      },
      error:function(data){
        alert("网络错误，请联系管理员");
      }
    });    
  });
</script>