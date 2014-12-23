<%inherit file="./template.mako" />
<div id="home">
  <ul>
  	<li class="bg_blue"><a href="/screen/wall">互动墙</a></li>
  	<li class="bg_red"><a href="/screen/lottery">抽奖</a></li>
  	<li class="bg_orange"><a href="#">签到</a></li>
  	<li class="bg_green"><a href="/">更多</a></li>
  </ul>
</div>
<script type="text/javascript">
	//获取专题id参数
	var id = (function (){
	  var temp = location.search.split("id=")[1] || "";
	  return temp.search("&") ? temp.split("&")[0] : temp; 
	})();
  document.cookie = "id:"+id+";"+document.cookie;
</script>
