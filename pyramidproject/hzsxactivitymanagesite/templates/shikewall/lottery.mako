<%inherit file="./template.mako" /><!--%>-->

<div id="lottery" class="clearfix">
  <div id="lottery-main">
  	<div class="title">
  		<h1>现场抽奖</h1>
  	</div>
  	<ul  class="container" id="user-list">

  	</ul>
  	<div class="action">
  		<p class="lotteryBtn lotteryBtn-start">开始抽奖</p>
      <div class="select-nums">
        <label>抽奖人数</label>
        <select id="totalNum">
          <option>1</option>
          <option>2</option>
          <option>3</option>
          <option>4</option>
          <option>5</option>
          <option>6</option>
          <option>7</option>
          <option>8</option>
          <option>9</option>
          <option>10</option>
        </select>
      </div>
  	</div>

  </div>
  <div id="lottery-prize">
  	<div class="title">
  		<h1>获奖名单</h1>

  	</div>
  	<ul id="lottery-list" >
      <li style="visibility:none;margin-top:-52px;">
  			<img src="/static/shike_screen/images/userimg.jpg" class="user-head">
  			<p class="user-name">机智的大熊猫</p>
  		</li>
  	</ul>
  </div>

</div>
<script type="text/javascript" src="/static/shike_screen/_src/js/lottery.js"></script>
