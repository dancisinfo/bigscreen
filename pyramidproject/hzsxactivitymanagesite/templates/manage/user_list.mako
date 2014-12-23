<%inherit file="mako_template.mako" />
<% import time %>

<div class="tabbable">
	%if event:
	<div class="widget">
	    <div class="widget-header" style="padding-left:10px">
	       <h3>${event.get('title','')}</h3>
	    </div>
	    <div class="widget-content" style="max-width:500px">
	    ${event.get('content') if event.get('content') else "" | n}
	    </div>
	</div>
	<ul class="nav nav-tabs">
	  <li><a href="/manage/feed_list?eventid=${request.params.get('eventid','')}">活动记录列表</a></li>
	  <li class="active"><a href="javascript:void(0)">活动用户列表</a></li>
	</ul>
	%endif
	%if table:
	<div class="widget">
	    <div class="widget-header" style="padding-left:10px">
	       <h3>${table.get('title','')}</h3>
	    </div>
	    <div class="widget-content">
	    ${table.get('content') if table.get('content') else "" | n}
	    </div>
	</div>
	<ul class="nav nav-tabs">
	  <li><a href="/manage/event_list?tid=${request.params.get('tid','')}">本专题活动列表</a></li>
	  <li class="active"><a href="javascript:void(0)">本专题关注者列表</a></li>
	</ul>
	%endif
	<div class="widget">
	    <div class="tab-pane" id="tab1">
		</div>
	    <div class="tab-pane active" id="tab2">
	    	<form class="form-search" method="get">
	    		<!--
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
				-->
			  	<input type="text" name="keyword" class="input-medium search-query" placeholder="用户关键字" value="${request.params.get('keyword','')}" />
			  	<button type="submit" class="btn">搜索</button>
			  	<!--<input type="reset" class="btn" value="清空" onclick="resetAll(this);return false;" />-->
			  	${parent.render_hidden_query()}
			</form>
	    	%if isinstance(lists, list) and len(lists)>0:
	        <table class="table table-striped table-bordered">
	            <thead>
	                <tr>
	                	<th style="width:65px;">头像</th>
	                    <th class="w-200">用户名</th>
	                    <th style="width:60px;">状态</th>
	                    <th>操作</th>
	                </tr>
	            </thead>
	            <tbody>
	            %for item in lists:
	                <tr>
	                	<td>
	                        <img src="${item.get("headimg","")}" style="width:60px;height:60px;">
	                    </td>
	                    <td>
	                        <a href="javascript:void(0)">
	                            <p>${item.get("name","")}</p>
	                        </a>
	                    </td>
	                    <td>
	                        <p>
	                          %if item.get("status",0)==-1:
	                            停用
	                          %elif item.get("status",0)==0:
	                            初始
	                          %elif item.get("status",0)==1:
	                            审核中
	                          %elif item.get("status",0)==2:
	                            审核通过
	                          %else:
	                            ${item.get("status",0)}
	                          %endif
	                        </p>
	                    </td>
	                    <td>	                    
	                    </td>
	                </tr>
	            %endfor
	            </tbody>
	        </table>
	        <div class="right_foot">
	            <div >${parent.makepager(count)}</div>
	      	</div>
	      	%endif
	    </div>
	</div>
</div>
<script type="text/javascript">
$(function(){
  $('#userlist').addClass('active');
})
</script>