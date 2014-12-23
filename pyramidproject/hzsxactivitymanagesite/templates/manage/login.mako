<!DOCTYPE html>
<html lang="zh-cn">
  <head>
    <meta charset="utf-8" />
    <title>时刻活动管理平台</title>
    <meta name="renderer" content="webkit">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <meta http-equiv="Cache-Control" content="no-siteapp" />
    <link rel="shortcut icon" href="/static/favicon.ico" type="image/vnd.microsoft.icon">
	<link rel="icon" href="/static/favicon.ico" type="image/vnd.microsoft.icon">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" />    
    <link rel="stylesheet" href="/static/css/bootstrap.min.css" />
    <link rel="stylesheet" href="/static/css/bootstrap-responsive.min.css" />
    <style>
        /*------------------------------------------------------------------
[1. Container / #login-container]
*/

#login-container {
	width: 425px;
	margin: 120px auto 0;

}

/*------------------------------------------------------------------
[2. Header / #login-header]
*/

#login-header {

	padding: 12px 20px;
	margin-bottom: 1em;

	background: #3C4049;
	background:-moz-linear-gradient(top, #4A515B 0%, #3C4049 100%); /* FF3.6+ */
	background:-webkit-gradient(linear, left top, left bottom, color-stop(0%,#4A515B), color-stop(100%,#3C4049)); /* Chrome,Safari4+ */
	background:-webkit-linear-gradient(top, #4A515B 0%,#3C4049 100%); /* Chrome10+,Safari5.1+ */
	background:-o-linear-gradient(top, #4A515B 0%,#3C4049 100%); /* Opera11.10+ */
	background:-ms-linear-gradient(top, #4A515B 0%,#3C4049 100%); /* IE10+ */
	background:linear-gradient(top, #4A515B 0%,#3C4049 100%); /* W3C */
	filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#4A515B', endColorstr='#3C4049');
	-ms-filter: "progid:DXImageTransform.Microsoft.gradient(startColorstr='#4A515B', endColorstr='#3C4049')";

	border-radius: 5px;

	text-shadow: 1px 1px 2px rgba(0,0,0,.5);
}

#login-header h3 {
	margin-bottom: 0;
    text-align: center;
	font-size: 16px;
	color: #FFF;

	text-decoration: 1px 1px 2px rgba(0,0,0,.4);
}



/*------------------------------------------------------------------
[3. Content / #login-content]
*/

#login-content {
	padding: 20px;

	background: #FFF;

	border: 1px solid #DDD;

	border-radius: 5px;

	box-shadow: 0 0 6px rgba(0,0,0,.10);
}

#login-content input {
	width: 96%;
	padding: 2% 2%;
}

#login-content #remember-me {
	margin-top: 3px;
}

#login-content #remember-me input {
	display: inline-block;

	width: auto;
	padding: 0;
}

#login-content #remember-me label {
	position: relative;
	top: 2px;

	display: inline-block;

	margin-left: .5em;
}



/*------------------------------------------------------------------
[4. Extra / #login-extra]
*/

#login-extra {
	margin-top: 1.5em;

	text-align: center;
}

#login-extra p {
	font-size: 12px;

	color: #888;
}

.error-message{color:#f00 !important;}


/*------------------------------------------------------------------
[5. Max Width: 480px]
*/

@media (max-width: 480px) {
	#login-container {
		width: 100%;
		margin: 40px auto 0;
	}
}
</style>
<body>
	
<div class="navbar navbar-fixed-top">
	
	<div class="navbar-inner">
		
		<div class="container">
			
			<a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse"> 
				<span class="icon-bar"></span> 
				<span class="icon-bar"></span> 
				<span class="icon-bar"></span> 				
			</a>
			
			<a class="brand" href="./">时刻活动管理平台</a>
			
			<div class="nav-collapse">
			
				<ul class="nav pull-right">
					
					<li class="">
						
						<a href="http://www.shike.im"><i class="icon-chevron-left"></i>时刻官网</a>
					</li>
				</ul>
				
			</div> <!-- /nav-collapse -->
			
		</div> <!-- /container -->
		
	</div> <!-- /navbar-inner -->
	
</div> <!-- /navbar -->


<div id="login-container">
	
	
	<div id="login-header">
		
		<h3>时刻活动管理平台</h3>
		
	</div> <!-- /login-header -->
	
	<div id="login-content" class="clearfix">
	
			<div>
				<fieldset>
					<div class="control-group">
						<label class="control-label" for="username">帐号</label>
						<div class="controls">
							<input type="text" class="" id="username" placeholder="手机号"/>
						</div>
					</div>
					<div class="control-group">
						<label class="control-label" for="password">密码</label>
						<div class="controls">
							<input type="password" class="" id="password" placeholder="密码"/>
						</div>
					</div>
				</fieldset>
				
				<div id="remember-me" class="pull-left">
					<input type="checkbox" name="remember" id="remember" />
					<label id="remember-label" for="remember">Remember Me</label>
				</div>
				
				<div class="pull-right">
					<button  class="btn btn-large btn-primary" id="loginbtn">
						登录
					</button>
				</div>
			</div>
			
		</div> <!-- /login-content -->
		
		
		<div id="login-extra">
			<p class="error-message"></p>
			<p>还没有帐号？<a href="javascript:;">赶紧注册一个吧！</a></p>
			
			<p>忘记密码？<a href="#">请戳这里！</a></p>
			
		</div> <!-- /login-extra -->
	
</div> <!-- /login-wrapper -->

    

<!-- Le javascript
================================================== -->
<!-- Placed at the end of the document so the pages load faster -->
<script src="/static/js/jquery-1.7.2.min.js"></script>
<script src="/static/js/bootstrap.js"></script>
  <script type="text/javascript">
    $(document).ready(function(){
    	document.getElementById("username").focus();
    	$("#loginbtn").click(ajax_login);
    	$(document).keydown(function(e){
	    	var key=e.which || e.keyCode;
	    	if(key == 13){
	    		ajax_login();
	    	}
	    });

    });
    
    function ajax_login(){
    	var msg={phone:$("#username").val(),password:$("#password").val()};
    	if(msg.phone == ""){
    		$(".error-message").html('请输入用户名');
    	}
    	else if(msg.password == ""){
    		$(".error-message").html('请输入密码');
    	}
    	else{
    		$.ajax({
		        url:"/pass/login",
		        data:msg,
		        dataType:"json",
		        success:function(data){
		          if(data.error){
		            $(".error-message").html(data.error);
		          }
		          else{
		          	window.location.href="/manage/home";
		          }
		        },
		        error:function(error){
		          $(".error-message").html('用户名或密码错误');
		        }
      		});
    	}
    }
  </script>
  </body>
</html>
