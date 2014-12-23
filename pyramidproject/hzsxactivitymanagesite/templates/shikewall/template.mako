<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <title>时刻大屏幕</title>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, user-scalable=0">
    <meta name="author" content="机智的大熊猫,开源小熊猫" />
    <meta name="renderer" content="webkit">
    <meta name="description" content=" " />
    <meta name="Keywords" content="微信墙,人人墙,微博墙,活动墙,前端网站,开源,GITHUB,免费,模板">

    <!-- <link rel="stylesheet" type="text/css" href="/static/shike_screen/css/style.min.css"> -->
    <link rel="stylesheet" type="text/css" href="/static/shike_screen/_src/css/reset.css">
    <link rel="stylesheet" type="text/css" href="/static/shike_screen/_src/css/base.css">
    <link rel="stylesheet" type="text/css" href="/static/shike_screen/_src/css/btn-icons.css">
    <link rel="stylesheet" type="text/css" href="/static/shike_screen/_src/css/home.css">
    <link rel="stylesheet" type="text/css" href="/static/shike_screen/_src/css/wall.css">
    <link rel="stylesheet" type="text/css" href="/static/shike_screen/_src/css/lottery.css">
    <link rel="stylesheet" type="text/css" href="/static/shike_screen/_src/css/checkin.css">
    

    <script src="http://libs.baidu.com/jquery/1.9.1/jquery.min.js"></script>
    <script>window.jQuery || document.write('<script src="/static/shike_screen/libs/jquery-1.9.1.min.js" type="text/javascript"><\/script>')</script>
    <!--<script src="/static/shike_screen/libs/slidr.js" type="text/javascript"></script>-->
    <script src="/static/shike_screen/_src/js/base.js"></script>
    
</head>
<body class="bg_christmas_red">
<div class="wrapper">
    <div id="header">
      <a href="/"><img src="/static/shike_screen/images/logo.png" alt="华中时讯-时刻" class="logo"></a>
      <div id="title">
        <h1>时刻大屏幕</h1>
        <h2>关注机智的大熊猫微信号：smart-X-panda</h2>
        <img src="/static/shike_screen/images/qrcode.png" alt="华中时讯-时刻" class="qrcode">
      </div>
    </div>
    <div id="main">
        ${next.body()}
    </div>
    <div id="footerMenu">
      <a href="#"><img src="/static/shike_screen/images/logo-b.png" alt="华中时讯-时刻" class="logo"></a>
      <ul id="menu">
        <li><a href="/screen/home" class="btn-icon btn-home">首页</a></li>
        <!-- <li><a href="#" class="btn-icon btn-checkin">签到</a></li> -->
        <!-- <li><a href="" class="btn-icon btn-style">皮肤</a></li> -->
        <li><a href="/screen/wall" class="btn-icon btn-tag">消息</a></li>
        <li><a href="/screen/lottery" class="btn-icon btn-lottery">抽奖</a></li>
        <!-- <li><a href="" class="btn-icon btn-vote">投票</a></li> -->
        <!-- <li><a href="" class="btn-icon btn-shake">摇一摇</a></li> -->
        <!-- <li><a href="" class="btn-icon btn-full">全屏</a></li> -->
        <div class="btn-func-container">
             <li><a href="" class="btn-func btn-old">最旧一页</a></li>
            <li><a href="" class="btn-func btn-prev">上一页</a></li>
            <li><a href="" class="btn-func btn-begin">开始</a></li>
            <li><a href="" class="btn-func btn-next">下一页</a></li>
            <li><a href="" class="btn-func btn-new">最新一页</a></li>
        </div>
      </ul>
    </div>
</div>
<script type="text/javascript">

</script>
</body>
</html>