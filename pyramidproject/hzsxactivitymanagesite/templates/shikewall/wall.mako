<%inherit file="./template.mako" /><!--%>-->
<div id="wall">
  <ul class="classic-wall" id="wall-list">
<!--     <li data-slidr="-1">
  		<div class="user-head">
  			<img src="/static/shike_screen/images/userimg.jpg">
  		</div>
  		<div class="user-content user-content-with-img">
  			<div>
  				<h1>天才小熊猫：<span>如何有时间的话在这里</span></h1>
  				<p>这里是我要说的话，怎么还不显示</p>
  			</div>
  			<img src="/static/shike_screen/images/userimg.jpg" class="user-content-img">
  		</div>
  	</li> -->
  </ul>
</div>
<script src="/static/shike_screen/_src/js/wall.js"></script>
<script type="text/javascript">
  $(document).ready(function(){
    g_wall.init();
  });
  
</script>
<!-- <button id="testBtn" style="position:fixed;bottom:0;height:100px;">测试按钮-添加评论</button> -->