<%inherit file="mako_template.mako" /><!--%>-->
<div class="btn-group ">
  <a href="/manage/event_list?tid=${request.params.get('tid','')}"><button class="btn btn-reverse">本专题所有活动</button></a>
  <a href="javascript:void(0)"><button class="btn btn-reverse active">新建活动</button></a>
</div>
<div class="widget">
    <div class="widget-header">
       <h3>新建活动</h3>
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
        <p>表单输入参数错误</p>
        %for x in form_errors:
          <p>${form_errors[x]}</p>
        %endfor
      </h1>
      
    %else:
        <form class="form-horizontal" role="form" >
            <fieldset>
              <!-- <div class="control-group">
                <label class="control-label" for="title"><i class="help-important">*</i>活动标题</label>
                <div class="controls">
                  <input type="text" placeholder="请输入活动标题" class="form-control" autofocus="on" maxlength="40" autocomplete="on" id="title" name="title">
                  <p class="help-block">标题长度不超过40字</p>
                </div>
              </div> -->
              <div class="form-group control-group alarm-starttime">
                <label for="alarm-starttime" class="control-label">活动时间</label>
                <div class="controls ">
                    <input class="form-control" size="16" type="text" value="" id="alarm-starttime">
                </div>
              </div>
            
              <div class="control-group">
                <label class="control-label" for="addr">活动地点</label>
                <div class=" controls">
                  <input type="text" placeholder="请输入活动地点" class="form-control" autocomplete="on" id="addr" name="addr" maxlength="30">
                  <p class="help-block">请输入活动地点,不超过30字</p>
                </div>
              </div>
              <div class="control-group">
                <label class="control-label" for="content">活动内容</label>
                <div class=" controls">
                <textarea name='content' class="form-control" style="min-height:100px;height:100%"></textarea>
                </div>
              </div>
              <div class="control-group ">
                <label class="control-label">&nbsp;</label>
                <div class="controls">
                  <span id="submit-btn" class="btn btn-primary">提交</span>
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
<!-- date picker -->
<script type="text/javascript" src="/static/js/bootstrap-datetimepicker.min.js" charset="UTF-8"></script>
<script type="text/javascript" src="/static/js/bootstrap-datetimepicker-controller.js" charset="UTF-8"></script>
<script type="text/javascript" src="/static/js/manage.js"></script>
<script>
  function getFormData(type,id){
  	var senddata={
      title: $("#title").val(),
      privacy: 1,
      content: $("textarea[name=content]").val(),
    }
    if($("#addr").val()!=""){
      senddata['addr']=$("#addr").val();
    }
    senddata['alarm.starttime']=$("input[name='alarm.starttime']").val();
    senddata['alarm.period']=$("#alarm-period").val();
    senddata['alarm.earlier']=$("#alarm-earlier").val();
	if(type == "edit"){
		if($("input[name=push]")[0].checked){
	    	var isPush=true;
	    }else{
	        isPush=false;
	    }
	    senddata['push']=isPush;
	    senddata['id']=id;
	}else{
		senddata['tableid']='${request.params.get('tid','')}';
	}
	return senddata;
  } 
  $("#submit-btn").click(function(){
    var senddata=getFormData("create","none");
    if(!senddata) return;
    $.ajax({
      url:"/proxy/event_create",
      data:senddata,
      type:"post",
      dataType:"json",
      success:function(data){
        if(data.form_errors){
          dispatchError(data.form_errors);
        }
        else{
          successReturn("/manage/event_list?tid=${request.params.get('tid','')}");
        }
      },
      error:function(data){
        alert("网络错误，请联系管理员");
      }
    });    
  });
  $("#alarm-period").change(function(){
    if($("#alarm-period").val() == "-1"){
      $(".alarm-starttime").fadeOut();
      $(".alarm-endtime").fadeOut();
      $("#alarm-period + .help-block").html("请选择提醒方式");
    }
    else{
      $(".alarm-starttime").fadeIn();
      $(".alarm-endtime").fadeIn();
      $("#alarm-period + .help-block").html("请输入提醒的开始时间和结束时间,结束时间可选填");
    }
  });
</script>