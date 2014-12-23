<%inherit file="mako_template.mako" />
<% import time %>
<div class="tabbable">
	%if table:
	<div class="widget">
	    <div class="widget-header" style="padding-left:10px">
	       <select id="select-table">
			  <option>${table.get('title','')}</option>
			</select>
			<a href="/manage/event_table_create" class="btn btn-primary pull-right">新建频道</a>
			<!-- <a href="/manage/event_create?tid=${table.get('_id','')}" class="btn btn-mini"
	       style="float:right;padding-right:10px;font-size:12px;line-height:30px;font-weight:bold;display:none;">创建活动</a> -->
	       
	    </div>
	</div>
	<div class="statis-container">
		<div class="statis-box">
	    	<div class="inner inner-blue">
	    		${table.get('content') if table.get('content') else "暂无描述" | n}
	    	</div>
	    </div>
	    <!-- user statistics-->
	    <div class="statis-box">
    		<div class="inner inner-green">
    			<a href="">
    				<p class="icon-manage icon-manage-msg"></p><p class="num">6</p><p class="info">新增消息</p>
    			</a>
    		</div>
		</div>
		<div class="statis-box">
    		<div class="inner inner-green">
    			<a href="">
    				<p class="icon-manage icon-manage-user"></p><p class="num">6</p><p class="info">新增人数</p>
    			</a>
    		</div>
		</div>
		<div class="statis-box">
    		<div class="inner inner-green">
    			<a href="">
    				<p class="icon-manage icon-manage-users"></p><p class="num">6</p><p class="info">总用户数</p>
    			</a>
    		</div>
		</div>
	</div>
<!-- 	<ul class="nav nav-tabs">
	  <li class="active"><a href="javascript:void(0)">本专题活动列表</a></li>
	  <li><a href="/manage/user_list?tid=${request.params.get('tid','')}">本专题关注者列表</a></li>
	  <li><a href="/manage/event_list">所有活动</a></li>
	</ul> -->
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
	  <li>
	    <a href="/manage/feed_list?userid=${request.params.get('userid','')}">用户所有活动记录</a>
	  </li>
	  <li class="active"><a href="javascript:void(0)">用户参与过的活动</a></li>
	  <!--<li><a href="/manage/event_list">所有活动</a></li>-->
	</ul>
	%else:
	<div class="btn-group">
	  <a href="/manage/event_list" class="btn btn-default">所有活动</a>
	</div>
	%endif
	<div class="widget">
	    
	    <div class="widget-content">    	
	    	<!-- <form class="form-search" method="get">
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
			  	<input type="text" name="keyword" class="input-medium search-query" placeholder="活动关键字" value="${request.params.get('keyword','')}" />
			  	<button type="submit" class="btn">搜索</button>
			  	<input type="reset" class="btn" value="清空" onclick="resetAll(this);return false;" />
			  	${parent.render_hidden_query()}
			</form> -->
	        %if isinstance(lists, list) and len(lists)>0:
	        <table class="table table-striped">
	            <thead>
	                <tr>
	                    <th>活动标题</th>
	                    <th>时间</th>
	                    <th>地点</th>
	                    <!--<th style="width:120px;">统计</th>-->
	                    <th>操作</th>
	                </tr>
	            </thead>
	            <tbody>
	            %for item in lists:
	                <tr>
	                    <td>
	                        <a href="/manage/feed_list?eventid=${item.get('_id','')}" title="查看本专题活动记录">
	                            <p>${item.get("title"," ")}</p>
	                            <!--${request.registry.settings['api_uri']}/share/event?id=${item['_id']}-->
	                        </a>
	                    </td>
	                    <td>
	                        <p>
	                          %if item.get("alarm"):
	                          <%
	                            week=["一","二","三","四","五","六","日"]
	                            localtime=time.localtime(item['alarm'].get('starttime')/1000)
	                          %>
	                          %if item["alarm"].get("period",0)==5:
	                            工作日 ${time.strftime("%H时%M分",localtime)}
	                          %elif item["alarm"].get("period",0)==1:
	                            每天 ${time.strftime("%H时%M分",localtime)}
	                          %elif item["alarm"].get("period",0)==2:
	                            每周${week[localtime.tm_wday]} ${time.strftime("%H时%M分",localtime)}
	                          %elif item["alarm"].get("period",0)==3:
	                            每月${time.strftime("%d日",localtime)} ${time.strftime("%H时%M分",localtime)}
	                          %else:
	                            ${time.strftime("%Y年%m月%d日 %H时%M分",localtime)}
	                          %endif
	                        %else:
	                          待定
	                        %endif
	                        </p>
	                    </td>
	                    <td>
	                        <p>${item.get("addr","待定")}</p>
	                    </td>
	                    <!--
	                    <td>
	                    <p>查看：${item.get("stat").get("view",0)}，添加：${item.get("stat").get("add",0)}<br/>喜欢：${item.get("stat").get("like",0)}，记录：${item.get("stat").get("feed",0)}</p>
	                    </td>-->
	                    <td>
	                    %if  item.get('isdeleted')==False:
	                    <a class="btn btn-mini" href="/manage/event_edit?eventid=${item.get('_id')}" title='${item.get('status')}'>编辑</a>
	                    %endif
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
	</div>
</div>
<script type="text/javascript">
	//切换专题事件
	$(document).ready(function(){
		var tableid='${table.get("_id") if table else "none"}';
		$.ajax({
	        url:'/api/event_table_list',
	        type:"get",
	        dataType:'json',
	        success:function(table){
	        	console.log(table)
	        	for(var i=0;i<table.length;i++){
	        		if(table[i][0] != tableid){
	        			$("#select-table").append('<option value="'+table[i][0]+'">'+table[i][1]+'</option>');
	        		}
	        	}
	        },
	        error:function(data){
	          // alert("");
	        }
	    });
	})
	$("#select-table").change(function(){
		var tid=$(this).find("option:selected").val();
		var cookie_lastid="tid="+"5486f0081d41c8154fda6a92"+";";
		document.cookie=cookie_lastid+document.cookie;
		window.location.href="/manage/event_list?tid="+tid;
	});
</script>
<script type="text/javascript">
  	function event_disable(eventid, enable){
		var action = "";
		if(enable==0){
			action = "封锁";
		}else if(enable==1){
			action = "恢复";
		}else{
			return false;
		}
		if(confirm("确定要" + action + "该专题")){
			$.ajax({
		        url:'/api/admin_event_enable',
		        type:"post",
		        data:{'eventid': eventid, 'enable': enable},
		        dataType:'json',
		        success:function(data){
		          if(data.error){
		          	alert(data.error)
		          }else{
		          	alert("设置成功");
		            //window.location.reload();
		          }
		        },
		        error:function(data){
		          alert("设置失败！（" + data + "）");
		        }
		    });
	  	}
	}
</script>
