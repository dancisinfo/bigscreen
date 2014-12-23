<%inherit file="mako_template.mako" />
<% 
import time
%>
<script type="text/javascript">
	// if(document.cookie.search("tid=")  !== -1){
 //  		//直接跳转到上次退出时所在专题页面
 //  		var tid=document.cookie.split(";")[0];
 //  		window.location.href="/manage/event_list?"+tid;
 //  	}
</script>
<div class="widget">
    <div class="widget-header">
       <h3 class="pull-left">专题列表 / 共20条专题</h3>
       <a href="/manage/event_table_create" class="btn btn-primary pull-right">新建频道</a>
    </div>
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
		  	<input type="text" name="keyword" class="input-medium search-query" placeholder="专题关键字" value="${request.params.get('keyword','')}" />
		  	<button type="submit" class="btn">搜索</button>
		  	<input type="reset" class="btn" value="清空" onclick="resetAll(this);return false;" />
		  	${parent.render_hidden_query()}
		</form> -->
        <div class="btn-group">
        	<!--<button class="btn btn-mini btn-primary">时间降序<i class="icon-arrow-down"></i></button>-->
        </div>
        %if isinstance(lists, list) and len(lists)>0:
        <table class="table table-striped table-border-top">
            <thead>
                <tr>
                	<th style="width:65px;">头像</th>
                    <th>专题名称</th>
<!--                     <th>更新时间</th> -->
                    <!--<th>状态</th>
                    <th>统计</th>-->
<!--                     <th>操作</th> -->
                </tr>
            </thead>
            <tbody>
            %for item in lists:
                <tr id='${item.get("_id")}'>
                	<td>
                        <img class='head' src="${item.get("headimg","")}" style="width:60px;height:60px;">
                    </td>
                    <td>
                        <a href='/manage/event_list?tid=${item.get('_id')}'><p>${item.get("title", "")}</p></a>
                        <!-- <button type="button" class="btnSetLargeImg">设置封面</button> 封面不要-->
                        <!--
                        % if item.get('largeimg'):
                         <a href="${item.get('largeimg')}" target="_blank"><p style="color: #d14;">有大图</p></a>
                        %else:
                        <p style="color: #d14;">无大图</p>
                        %endif
                        -->
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
<div id="setLargeImg" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
  <div class="modal-header">
    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
    <h3 id="myModalLabel">专题封面</h3>
  </div>
  <div class="modal-body">
	<div class="controls">
		<div id="qiniu_container"><a class="btn btn-default btn-lg " id="pickfiles" href="#" >上传封面图片</a></div>
		<div id="preview_box">
			<img src="" id="preview_img" alt="封面图片" />
			<input name="qiniu-src" type="hidden" value="" />
		</div>
		<p class="help-block">建议图片尺寸为400pxx300px,只支持jpg,png,jpeg格式</p>
	</div>
  </div>
  <div class="modal-footer">
    <button class="btn" data-dismiss="modal" aria-hidden="true">关闭</button>
    <button class="btn btn-primary">保存</button>
  </div>
</div>
<!--?ueditor  -->
<script type="text/javascript" charset="utf-8" src="/static/ueditor1_2_6_1/ueditor.config.js"></script>
<script type="text/javascript" charset="utf-8" src="/static/ueditor1_2_6_1/ueditor.all.js"></script>
<script type="text/javascript" src="/static/ueditor1_2_6_1/lang/zh-cn/zh-cn.js"></script>
<!--七牛-->
<script type="text/javascript" src="/static/qiniu_upload/plupload/moxie.min.js"></script>
<script type="text/javascript" src="/static/qiniu_upload/plupload/plupload.dev.js"></script>
<script type="text/javascript" src="/static/qiniu_upload/qiniu.min.js"></script>
<script type="text/javascript" src="/static/js/qiniu_upload.config.js"></script>
<script type="text/javascript">
	function set_event_table_mode(tid, mode){
		$.ajax({
	        url:'/api/set_event_table_mode',
	        type:"post",
	        data:{'tid': tid, 'mode': mode},
	        dataType:'jsonp',
	        success:function(data){
	          if(data.error){
	          	alert(data.error)
	          }else{
	          	alert("设置成功");
	            window.location.reload();
	          }
	        },
	        error:function(data){
	          alert("设置失败！（" + data + "）");
	        }
	    });
	}
	function set_event_table_privacy(tid, privacy){
		$.ajax({
	        url:'/api/set_event_table_privacy',
	        type:"post",
	        data:{'tid': tid, 'privacy': privacy},
	        dataType:'jsonp',
	        success:function(data){
	          if(data.error){
	          	alert(data.error)
	          }else{
	          	alert("设置成功");
	            window.location.reload();
	          }
	        },
	        error:function(data){
	          alert("设置失败！（" + data + "）");
	        }
	    });
	}
	$(document).ready(function(){
		$('#eventtablelist').addClass('active');
		$(".btnSetLargeImg").click(function(){
			var container = $(this).parents("tr");
			var tid = container.attr("id");
			$("#preview_img")[0].src='';
			var ins = $("#setLargeImg").modal({});
			ins.find(".btn-primary").click(function(){
			 	var imageurl = $("input[name=qiniu-src]").val();
			 	if(imageurl!=undefined && imageurl!=""){
				 	$.ajax({
				        url:'/api/table_set_headimg',
				        type:"post",
				        data:{'tid': tid, 'imageurl': imageurl},
				        dataType:'json',
				        success:function(data){
				          if(data.error){
				          	alert(data.error)
				          }else{
				            //window.location.reload();
				            container.find('img[class=head]').attr('src', imageurl+'-head')
				          }
				          ins.modal("hide");
				        },
				        error:function(data){
				          alert("设置失败！（" + data + "）");
				        }
				    });
			 	}
			});
		});
	});
</script>
