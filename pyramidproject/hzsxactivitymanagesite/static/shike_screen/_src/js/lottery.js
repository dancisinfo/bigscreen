// lottery.js
var g_lottery = {
	DATA:{},//参与抽奖的总人数
	totalNum:1,//一次性抽奖的人数
	prizers:[],//已中奖用户
	timerRandomBox:null,//选择框计时器
	timerRandomUser:null,//用户图像计时器
	//使用前调用此函数初始化
	initData:function(){
		$.ajax({
	      url:"/api/wall_users",
	      data:{
	        'eventid':getCookieVal("id")
	      },
	      type:"get",
	      dataType:"json",
	      success:function(user){
	      	g_lottery.DATA=user;
	      	// console.log(g_lottery.DATA)
	        g_lottery.addUser(g_lottery.DATA);
	    	g_lottery.addstartGameListener();
	        
	      },
	      error:function(data){
	        alert("网络错误，请联系管理员");
	      }
	    });
	},
	//添加抽奖按钮点击事件
	addstartGameListener: function(){
		$(".lotteryBtn").click(function(){
			if($(".lotteryBtn").hasClass("lotteryBtn-start")){
				if(g_lottery.totalNum <= 1){
					g_lottery.randomBox();
					g_lottery.randomUser();
					$(".lotteryBtn").html("确 认")
						.addClass("lotteryBtn-stop")
						.removeClass("lotteryBtn-start");
				}
				else{
					// 多次抽奖
					g_lottery.multiLottery(g_lottery.totalNum);
				}
			}
			else{
				//清楚游戏定时器
				clearInterval(g_lottery.timerRandomBox);
				clearInterval(g_lottery.timerRandomUser);
				//添加中奖者到中奖列表
				g_lottery.addPrizer($("#user-list").find("li.selected-li"));
				//重置抽奖按钮
				$(".lotteryBtn").html("开始抽奖")
					.addClass("lotteryBtn-start")
					.removeClass("lotteryBtn-stop");
			}

		})
	},
	removestartGameListener: function(){

	},
	//将中奖用户添加到中奖列表
	addPrizer:function(selectedDOM){
		var prizer={
				'headimg':selectedDOM.find("img")[0].src,
				'name':selectedDOM.find(".user-name").text()
			};
		g_lottery.prizers.push(prizer.name);
		//添加中奖者元素box
		var $box = $('<div id="prizer-temp-box"><img src="'+prizer.headimg+'"><p>'+prizer.name+'</p></div>');
		$box.css({
			'left':selectedDOM.offset().left+"px",
			'top':selectedDOM.offset().top+"px",
		});
		$("body").append($box);
		//播放中奖动画
		var top=(function(){
			var h1=$("#lottery-list li:last-child").offset().top+$("#lottery-list li").height(),
				h2=$("#lottery-list").offset().top+$("#lottery-list").height();
			//让滚动条始终在底部
			$("#lottery-list").scrollTop($("#lottery-list li:last-child").position().top);
			return ( h1< h2) ? h1:h2;
		})();
		var left=$("#lottery-list li:last-child").offset().left;
		$box.animate({
			'width':'200px',
			'height':'200px',
			'left':left+'px',
			'top':top+'px'
		},1000,function(){
			$box.animate({
				'width':'50px',
				'height':'50px'
			},500,function(){
				//将中奖者信息加入中奖列表
				var str = '<li><img src="'+prizer.headimg+'" class="user-head">'+
		  				'<p class="user-name">'+prizer.name+'</p></li>'
				$("#lottery-list").append(str);
				//销毁$box
				$box.remove(); 
			})
		});

	},
	//添加用户到随机列表
	addUser: function(items){
		var i,str;
		for(i=0;i<items.length;i++){
			var str='<li><img src="'+items[i].headimg+'" class="user-head">'+
  					'<p class="user-name">'+items[i].name+'</p></li>';

  			$("#user-list").append(str);
		}
	},
	/*抽奖随机算法：考虑到参加大屏幕活动的人都比较多，所以抽奖时分为中奖框随机和用户图像随机
	* 屏幕上一次最多显示BoxLength <=15 个头像框Boxes,选择框在这些Boxes中随机
	*/
	randomBox:function(){
		var listNum = $("#user-list").children().length;
		var randomNum;
		var BoxLength = 15;
		var $selected;
		if(listNum < 15){
			BoxLength=listNum;
		}
		g_lottery.timerRandomBox = setInterval(function(){
			$("#user-list").find("li.selected-li").removeClass("selected-li");
			randomNum = parseInt(Math.random()*BoxLength);
			$selected = $($("#user-list").children()[randomNum]);
			$selected.addClass("selected-li")
		},50);
	},
	/*用户图像随机算法：用户总数listLength，在BoxLength个Boxes之间随机，确保每一个用户都有被选中的可能
	* 同一时间屏幕上不能出现相同用户，已中奖用户不在参与随机
	*/
	randomUser:function(){
		var listLength = g_lottery.DATA.length;
		var BoxLength = 15;
		if(listLength < 15){
			BoxLength=listLength;
		}
		var randomBoxNum,randomlistNum;
		var imgheadArr=$("#user-list .user-head");
		var usernameArr=$("#user-list .user-name");

		g_lottery.timerRandomUser = setInterval(function(){
			randomBoxNum = parseInt(Math.random()*BoxLength)
			do{
				//确保已中奖用户不在加入大屏幕
				randomlistNum = parseInt(Math.random()*listLength);
			}while(g_lottery.prizers.indexOf(g_lottery.DATA[randomlistNum].name) !== -1)

			$(usernameArr[randomBoxNum]).text(g_lottery.DATA[randomlistNum].name);
			imgheadArr[randomBoxNum].src=g_lottery.DATA[randomlistNum].headimg;
		},50);
	},
	//多次抽奖
	multiLottery: function(times){
		if(times > g_lottery.DATA.length){
			alert("总人数不足"+times+"人，请减少抽奖人数！");
			return;
		}
		g_lottery.randomBox();
		g_lottery.randomUser();
		$(".lotteryBtn").addClass("lotteryingBtn").removeClass("lotteryBtn").text("正在抽奖中");

		var multimer = setInterval(function(){
			if(times == 0){
				clearInterval(multimer);
				clearInterval(g_lottery.timerRandomBox);
				clearInterval(g_lottery.timerRandomUser);
				//重置抽奖按钮
				$(".lotteryingBtn").addClass("lotteryBtn")
					.removeClass("lotteryingBtn")
					.addClass("lotteryBtn-start")
					.removeClass("lotteryBtn-stop")
					.text("继续抽奖");
				return;
			}
			g_lottery.addPrizer($("#user-list").find("li.selected-li"));
			console.log(times--)
		},3000);

	},
	getTotalNumListener:function(){
		$("#totalNum").change(function(){
			g_lottery.totalNum = parseInt($("#totalNum option:selected").val());
		})
	}
};

$(document).ready(function(){
	g_lottery.initData();
	g_lottery.getTotalNumListener();
});