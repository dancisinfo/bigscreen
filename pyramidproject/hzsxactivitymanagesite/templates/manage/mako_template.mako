<!DOCTYPE html>
<html lang="zh-cn">
<head>
<title>时刻-活动管理平台</title>
<meta charset="UTF-8" />
<meta name="renderer" content="webkit">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
<meta http-equiv="Cache-Control" content="no-siteapp" />
<link rel="shortcut icon" href="/static/favicon.ico" type="image/vnd.microsoft.icon">
<link rel="icon" href="/static/favicon.ico" type="image/vnd.microsoft.icon">
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<link rel="stylesheet" href="/static/css/bootstrap.min.css" />
<link rel="stylesheet" href="/static/css/bootstrap-responsive.min.css" />
<link rel="stylesheet" href="/static/css/font-awesome.min.css"  />
<link rel="stylesheet" href="/static/css/datepicker.css" />
<link rel="stylesheet" href="/static/css/bootstrap-datetimepicker.min.css" />
<link rel="stylesheet" href="/static/css/adminia.css" />
<link rel="stylesheet" href="/static/css/adminia-responsive.css" />
<link rel="stylesheet" href="/static/css/base.css"  />
<!-- <link rel="stylesheet" href="/static/css/manage.css"  /> -->
<!-- ueditor -->
<link href="/static/ueditor1_2_6_1/themes/default/css/ueditor.css" type="text/css" rel="stylesheet">
<!--[if lt IE 9]>
    <script src="http://cdn.bootcss.com/html5shiv/3.7.2/html5shiv.min.js"></script>
    <script src="http://cdn.bootcss.com/respond.js/1.4.2/respond.min.js"></script>
<![endif]-->
<!--[if lt IE 7]>
    <link rel="stylesheet" href="/static/css/font-awesome-ie7.min.css"  />
<![endif]-->
<!--?<link rel="stylesheet" href="/static/css/fullcalendar.css" />-->
<!--?<link rel="stylesheet" href="/static/css/matrix-style.css" />-->
<!--?<link rel="stylesheet" href="/static/css/matrix-media.css" />-->

<!--?<link rel="stylesheet" href="css/jquery.gritter.css" />-->
<script src="/static/js/jquery-1.7.2.min.js"></script>
</head>
<body>
<header class="navbar navbar-inverse navbar-fixed-top">
  <div class="navbar-inner">
    <div class="container">
      <a data-target=".navbar-responsive-collapse" data-toggle="collapse" class="btn btn-navbar">
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
      </a>
      <a href="/manage/home" class="brand">时刻活动管理平台</a>
      <div class="nav-collapse collapse navbar-responsive-collapse">
        <ul class="nav pull-right">
          <li class="divider-vertical"></li>
          <li class="dropdown">
              <a data-toggle="dropdown" class="dropdown-toggle" href="#">${request.user.get("name")}<b class="caret"></b></a>
            <ul class="dropdown-menu">
              <li><a href="/pass/logout">退出登录</a></li>
            </ul>
          </li>
        </ul>
      </div>
      <!-- /.nav-collapse -->
    </div>
  </div>
  <!-- /navbar-inner -->
</header>
<section id="content">
    <div class="container">
        ${self.body()}
    </div>
</section>
<footer class="navbar navbar-inverse  navbar-fixed-bottom">
  <div class="navbar-inner">
	  <section class="container">
		  <p>&copy;2015 武汉华中时讯科技有限责任公司</p>
 	  </section>
  </div>
</footer>
<script src="/static/js/bootstrap.js"></script>
<script src="/static/js/bootstrap-datepicker.js"></script>
<script src="/static/js/bootstrap-datepicker.zh-CN.js"></script>
<script src="/static/js/bootstrap-datepicker.controller.js"></script>
<%block name="script" />
<script type="text/javascript">
function resetAll(container){
  	$(container).parent("form").find("input").each(
  		function(){
			switch(this.type){
				case 'hidden':
				case 'text':
                	$(this).val('');break;  
                case 'checkbox':  
                case 'radio':  
                	this.checked = false;  
            }
  		}
  	);
  }
</script>
</body>
<%def name="makepager(count)">
	<ul class="pagination">
		<%
          	querystring = request.query_string.split('&page')[0].split('page')[0]
          	if len(querystring)>0:
          		querystring = '?%s&' % querystring
          	else:
          		querystring = '?'
          	page = 	str(request.params.get('page',1))
          	if not page.isdigit():
          		page = 1
          	page=int(page)
         %>
        %if count and count>1:
          %if page>0:
            <li><a href="${querystring}page=1" title="首页">首页</a></li>
          %endif
          %if page>=2:
            <li><a href="${querystring}page=${page-1}" class="prev" title="上一页"> 上一页</a></li>
          %endif
          %for i in range(page - 3,page):
            %if i>=1:
              <li><a href="${querystring}page=${i}" class="number" title="${i}">${i}</a></li>
            %endif
          %endfor
          <li><a href="javascript:void(0)" class="number current" title="${page}">${page}</a></li>
          %for i in range(page+1, page + 3):
            %if i<=count/20+1:
              <li><a href="${querystring}page=${i}" class="number" title="${i}"> ${i} </a></li>
            %endif
          %endfor
          %if page<(count/20+1):
            <li><a href="${querystring}page=${page+1}" class="next" title="下一页">下一页 </a></li>
          %endif
          %if count>0:
            <li><a href="${querystring}page=${count/20+1}" title="尾页">尾页 </a></li>
          %endif
        %else:
        %endif
	</ul>
</%def>
<%def name="render_hidden_query(arr=['keyword','starttime','endtime'])">
	% for key, val in request.params.items():
		%if key not in arr and val!='':
			<input name="${key}" type=hidden value="${val}" />
	    %endif
	% endfor
</%def>