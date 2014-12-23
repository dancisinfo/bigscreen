function getCookieVal(key){
	try{
		var val = document.cookie.split(key+":")[1].split(";")[0];
		return val;
	}
	catch(e){
		throw new Error("获取cookie值失败,请验证cookie和参数值")
	}
	
}
var SCREEN={
	fullMode:function(){
	  if(document.body.webkitRequestFullScreen){  
          document.body.webkitRequestFullScreen();     
      }else if(document.body.mozRequestFullScreen){  
          document.body.mozRequestFullScreen();  
      }else if(document.body.requestFullScreen){  
          document.body.requestFullscreen();  
      }else{  
          //浏览器不支持全屏API或已被禁用  
      } 
	},
	windowMode:function(){
	  if(document.body.webkitCancelFullScreen){  
          document.body.webkitCancelFullScreen();      
      }else if(document.body.mozCancelFullScreen){  
          document.body.mozCancelFullScreen();  
      }else if(document.body.cancelFullScreen){  
          document.body.cancelFullScreen();  
      }else if(document.body.exitFullscreen){  
          document.body.exitFullscreen();  
      }else{  
          //浏览器不支持全屏API或已被禁用  
      }  
	},
	btnAction:function(){
		var cls;
		$("#menu").delegate("a","click",function(){
			$(this).preventDefault();
			// cls = $(this).attr("class")
		});	
	},
	init:function(){
		$(document).keypress(function(e){
	      switch(e.keyCode){
	        case 13://enter 全屏
	          SCREEN.fullMode(); 
	          break;
	        case 27://Escape 退出全屏
	          SCREEN.windowMode();
	          break;
	        default:
	          break;
	      };
	    });
	}
};
$(document).ready(function(){
	SCREEN.init();
	//二维码点击放大效果
	$(".qrcode").click(function(){
	    var $qrcode=$(this);
	    if($qrcode.css("z-index") != "10086"){
	      $qrcode.animate({
	        'width':'500px',
	        'height':'500px',
	        'right':'50%',
	        'margin-top':'50px',
	        'margin-right':'-250px',
	        'z-index':'10086'
	      },500);
	    }
	    else{
	      $qrcode.animate({
	        'width':'100px',
	        'height':'100px',
	        'right':'0',
	        'margin-top':'0',
	        'margin-right':'0',
	        'z-index':'1000'
	      },500);
	    }
	});
});
$(window).load(function(){
	//
});
