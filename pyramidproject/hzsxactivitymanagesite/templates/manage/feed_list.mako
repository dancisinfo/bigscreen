<%inherit file="mako_template.mako" />
<% import time %>
<div class="tabbable">
	%if event:
	<div class="widget">
	    <div class="widget-header" style="padding-left:10px">
	       <h3 class="pull-left">${event.get('title','')}</h3>
	       <a href="/screen/home?id=${event.get('_id','')}" class="btn btn-primary pull-right">活动大屏幕</a>
	    </div>
	    <div class="widget-content" style="max-width:500px">
	    ${event.get('content') if event.get('content') else "" | n}
	    </div>
	</div>
	<ul class="nav nav-tabs">
	  %if request.params.get('iswall'):
	  <li><a href="/manage/feed_list?eventid=${request.params.get('eventid','')}">活动记录列表</a></li>
	  <li class="active"><a href="javascript:void(0)">上墙记录</a></li>
	  %else:
	  <li class="active">
	    <a href="javascript:void(0)">活动记录列表</a>
	  </li>
	  <li><a href="/manage/feed_list?eventid=${request.params.get('eventid','')}&iswall=true">上墙记录</a></li>
	  %endif
	  <li><a href="/manage/user_list?eventid=${request.params.get('eventid','')}">活动用户列表</a></li>
	  <!--<li><a href="/manage/feed_list">所有活动记录</a></li>-->
	</ul>
	%elif user:
	<div class="widget">
	    <div class="widget-header" style="padding-left:10px">
	       <h3>${user.get('name','')}</h3>
	    </div>
	    <div class="widget-content">
	    ${user.get('description','') if user.get('description','') else "" | n}
	    </div>
	</div>
	<ul class="nav nav-tabs">
	  <li class="active">
	    <a href="javascript:void(0)">用户所有活动记录</a>
	  </li>
	  <li><a href="/manage/event_list?userid=${request.params.get('userid','')}">用户参与过的活动</a></li>
	  <!--<li><a href="/manage/feed_list">所有活动记录</a></li>-->
	</ul>
	%else:
	<div class="widget">
	    <ul class="nav nav-tabs">
		  %if request.params.get('iswall'):
		  <li><a href="/manage/feed_list">所有活动记录</a></li>
		  <li class="active"><a href="javascript:void(0)">上墙记录</a></li>
		  %else:
		  <li class="active"><a href="javascript:void(0)">所有活动记录</a></li>
		  <li><a href="/manage/feed_list?eventid=${request.params.get('eventid','')}&iswall=true">上墙记录</a></li>
		  %endif
		</ul>
	</div>
	%endif
	<div class="widget">
	    <div class="tab-pane active" id="tab1">
	    	<form class="form-search" method="get">
				<div class="input-append date" id="starttime">
				  <input id="starttime" class="span2" size="16"  type="text" value="">
				  <span class="add-on"><i class="icon-th">开始</i></span>
				</div>
				<input type="hidden" name="starttime" value="${request.params.get('starttime','')}">
				<div class="input-append date" id="endtime">
				  <input class="span2" size="16"  type="text" value="">
				  <span class="add-on"><i class="icon-th">结束</i></span>
				</div>
				<input type="hidden" name="endtime" value="${request.params.get('endtime','')}">
			  	<input type="text" name="keyword" class="input-medium search-query" placeholder="活动记录关键字" value="${request.params.get('keyword','')}" />
			  	<button type="submit" class="btn">搜索</button>
			  	<!--<input type="reset" class="btn" value="清空" onclick="resetAll(this);return false;" />-->
			  	${parent.render_hidden_query()}
			</form>
	        %if isinstance(lists, list) and len(lists)>0:
	        <table class="table table-striped table-border-top">
	            <thead>
	                <tr>
	                    <th class="w-150">记录内容</th>
	                    <th class="w-150">用户</th>
	                    <th class="w-150">所在活动</th>
	                    <th>统计</th>
	                    <th>操作</th>
	                </tr>
	            </thead>
	            <tbody>
	            %for item in lists:
	                <tr>
	                    <td>
	                    <p>${item.get("content"," ")}</p>
	                    </td>
	                    <td>
	                        <p><a href="/manage/feed_list?userid=${item.get('user',{}).get('_id','')}" title="用户活动记录">${item.get("user",{}).get("name","")}</a></p>
	                    </td>
	                    <td>
	                        <p><a href="/manage/feed_list?eventid=${item.get('event',{}).get('_id','')}" title="该活动的所有记录">${item.get("event",{}).get("title","")}</a></p>
	                    </td>
	                    <td>
	                        <p></p>
	                    </td>
	                    <td>
	                        <p>
	                        %if item.get('iswall'):
	                        <a class="btn btn-mini" href="javascript:set_feed_wall('${item.get('_id')}', false)">取消上墙</a>
	                        %else:
	                        <a class="btn btn-mini" href="javascript:set_feed_wall('${item.get('_id')}', true)">上墙</a>
	                        %endif
	                        </p>
	                    </td>
	                </tr>
	            %endfor
	            </tbody>
	        </table>
	        <div class="right_foot">
	            <div >
	              ${parent.makepager(count)}
	            </div>
	      </div>
	      %endif
	    </div>
	    <div class="tab-pane" id="tab2">
	    </div>
	</div>
</div>
<script type="text/javascript">
  $(function(){
  	$('#feedlist').addClass('active');
  });
  function set_feed_wall(feedid, iswall){
		var action = "";
		if(iswall){
			action = "上墙";
		}else{
			action = "取消上墙";
		}
		if(confirm("确定对该活动记录进行" + action + "操作")){
			$.ajax({
		        url:'/api/set_feed_wall',
		        type:"post",
		        data:{'feedid': feedid, 'iswall': iswall},
		        dataType:'json',
		        success:function(data){
		          if(data.error){
		          	alert(data.error)
		          }else{
		          	//alert("设置成功");
		            window.location.reload();
		          }
		        },
		        error:function(data){
		          alert("设置失败！（" + data + "）");
		        }
		    });
	  	}
	}
</script>