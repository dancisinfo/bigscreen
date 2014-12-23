<%inherit file="mako_template.mako" />
<% import time %>
<div class="btn-group ">
  <a href="/manage/event_list?tid=${event.get('table').id if event and event.get('table') else ''}"><button class="btn btn-reverse">本专题所有活动</button></a>
  <a href="javascript:void(0)"><button class="btn btn-reverse active">修改活动</button></a>
</div>
<div class="widget">
    <div class="widget-header">
       <h3>编辑日程</h3>
    </div>
    <div class="widget-content">
    <form class="form-horizontal" role="form" >
      <fieldset>
        <div class="control-group">
          <label class="control-label" for="title" >日程标题</label>
          <div class="controls">
            <input type="text"  value="${event.get('title','')}" class="form-control" autofocus="on" maxlength="40" autocomplete="on" id="title" name="title">
            <p class="help-block">标题长度不超过40字</p>
          </div>
        </div>
        
		  <div class="form-group control-group alarm-starttime">
		    <label for="alarm-starttime" class="control-label">活动时间</label>
		    <input type="hidden" name="alarm.starttime" value="${event.get('alarm',{}).get('starttime',0)}" id="alarm-starttime-hidden">
		    <div class="controls ">
		    	<% localtime=time.localtime(event.get('alarm',{}).get('starttime',0)/1000) %>
		        <input class="form-control" size="16" type="text" value="${time.strftime('%Y-%m-%d %H:%M:%S',localtime)}" id="alarm-starttime">
		    </div>
		  </div>
		  
		  <div class="control-group">
		    <label class="control-label" for="alarm-period">设置提醒方式</label>
		    <div class=" controls">
		      <select class="form-control" name="none" id="alarm-period">
		        <option value="0" selected="selected" >单次提醒</option>
		        <option value="1" >每天提醒</option>
		        <option value="2" >每周提醒</option>
		        <option value="3" >每月提醒</option>
		        <option value="4" >每年提醒</option>
		      </select>
		      <p class="help-block">请选择提醒方式</p>
		    </div>
		  </div>
		  <div class="control-group">
		    <label class="control-label" for="alarm-earlier">设置提醒提前时间</label>
		    <div class="controls">
		        <select class="form-control" name="none" id="alarm-earlier">
		        <option value="0" selected="selected">不提前</option>
		        <option value="${10*60}" >提前10分钟</option>
		        <option value="${30*60}" >提前30分钟</option>
		        <option value="${3600}" >提前1小时</option>
		        <option value="${2*3600}" >提前2小时</option>
		        <option value="${6*3600}" >提前6小时</option>
		        <option value="${24*3600}" >提前1天</option>
		      </select>
		      <p class="help-block">请选择提醒提前时间</p>
		    </div>
		</div>
        <div class="control-group">
          <label class="control-label  " for="addr">日程地点</label>
          <div class=" controls">
            <input type="text" value="${event.get('addr','')}" class="form-control" autocomplete="on" id="addr" name="addr" maxlength="30">
            <p class="help-block">请输入日程地点,不超过30字</p>
          </div>
        </div>
        <!--
        <div class="control-group">
          <label class="control-label  " for="content">日程内容</label>
          <div class=" controls">
            <textarea name='content' class="form-control" style="min-height:100px;height:100%">${event.get('content','')}</textarea>
          </div>
        </div>
        <div class="control-group">
          <label class="control-label  ">是否推送</label>
          <div class="controls">
            <label class="radio inline">
              <input type="radio" name="push" value="true" checked="checked">是
            </label>
            <label class="radio inline">
              <input type="radio" name="push" value="false">否
            </label>
          </div>
        </div>
        -->
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
  </div>
</div>
<!-- date picker -->
<script type="text/javascript" src="/static/js/bootstrap-datetimepicker.min.js" charset="UTF-8"></script>
<script type="text/javascript" src="/static/js/bootstrap-datetimepicker-controller.js" charset="UTF-8"></script>
<script type="text/javascript" src="/static/js/manage.js"></script>
<script type="text/javascript" src="/static/js/manage.js"></script>
<script type="text/javascript">
    function getFormData(type,id){
		var senddata={
	      title:$("#title").val(),
	      privacy:1
	      //content:$("textarea[name=content]").val(),
	    }
	    if($("#addr").val()!=""){
	      senddata['addr']=$("#addr").val();
	    }
	    senddata['alarm.starttime']=$("input[name='alarm.starttime']").val();
    	senddata['alarm.period']=$("#alarm-period").val();
    	senddata['alarm.earlier']=$("#alarm-earlier").val();
	    if(type == "edit"){
	    /**
	      if($("input[name=push]")[0].checked){
	        var isPush=true;
	      }
	      else{
	        isPush=false;
	      }
	      senddata['push']=isPush;
	    **/
	      senddata['id']=id;
	    }else{
	    	senddata['tableid']='${request.params.get('tid','')}';
	    }
	    return senddata;
  	}
  	$(function(){
	    %if event.get("alarm"):
	      $("#alarm-period option[value=${event['alarm'].get('period',-1)}]").attr("selected","selected");
	      $("#alarm-earlier option[value=${event['alarm'].get('earlier',-1)}]").attr("selected","selected");
	    %endif
    })
    $("#submit-btn").click(function(){
      var senddata=getFormData("edit",'${request.params.get("eventid")}');
      if(!senddata) return;
      $.ajax({
        url:"/proxy/event_edit",
        data:senddata,
        type:"post",
        dataType:"json",
        success:function(data){
          if(data.form_errors){
            dispatchError(data.form_errors);
          }
          else{
            successReturn("/manage/event_list?tid=${event.get('table',{}).id if event else ''}");
          }
        },
        error:function(data){
          alert("网络错误，请联系管理员");
        }
      });
    });
  </script>