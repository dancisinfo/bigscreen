// g_wall.js

var g_wall = {
  //服务端返回的数据
  data:new Array(),
  //是否暂停/播放
  isPlaying:false,
  //定时器指针
  autoplayTimer:null,
  //幻灯片播放间隔时间
  slideDurationTime:3000,
  //一次添加所有用户信息上墙,过滤不合格评论
  addUsers2Wall:function(items){
    var str,i,j,flag;
    var idArr = new Array();
    var list = $("#wall-list").children() || [];
    for(j = 0; j< list.length;j++){
      i = $(list[j]).attr("data-id") || "";
      idArr.push(i);
    }
    
    $("#wall-list li").attr("data-fresh","old");

    for(i = 0;i<items.length;i++){
      //在原列表中查找评论，如果有,flag置为true,更新fresh状态，不插入str
      flag = false;
      for(j = 0; j< idArr.length; j++){
        if(items[i]["_id"] === idArr[j]){
          $(list[j]).attr("data-fresh","new");
          flag = true;
          break;
        }
      }
      if(flag === true){
        continue;
      }
      //如果在原列表中没有找到，则是新提交的评论
      if(!items[i].content){items[i].content="用户啥也没说"}
      if(items[i].image){
        str = '<li data-fresh="new" data-id = "'+items[i]["_id"]+'"><div class = "user-head"><img src = "'+items[i].user.headimg+'"></div>'+
            '<div class = "user-content user-content-with-img"><div><h1>'+items[i].user.name+'：<span>如何有时间的话在这里</span></h1>'+
            '<p>'+items[i].content+'</p></div><img src = "'+items[i].image.thumbnail+'" class = "user-content-img"></div></li>';
      }
      else{
         str = '<li data-fresh="new" data-id = "'+items[i]["_id"]+'"><div class = "user-head"><img src = "'+items[i].user.headimg+'"></div>'+
            '<div class = "user-content"><div><h1>'+items[i].user.name+'：<span>如何有时间的话在这里</span></h1>'+
            '<p>'+items[i].content+'</p></div></div></li>'; 
      }
      $("#wall-list").append(str);
    }

    //所有data-fresh=old的评论都是过期评论
    $("#wall-list li[data-fresh='old']").remove();

  },
  //改变墙的呈现方式 三栏模式/幻灯片模式
  changeWallMode:function(){
    $("#wall-list").delegate('li','click',function(){
      var imgs = $("#wall-list .user-content-img");
      var i;
      if($('#wall-list').hasClass("slidr-wall")){
        //三栏模式
        $("#wall-list").removeClass("slidr-wall");
        for(i = 0;i<g_wall.data.length && g_wall.data[i].image;i++){
          imgs[i].src = g_wall.data[i].image.thumbnail;
        }
      }
      else{
        //幻灯片模式
        $("#wall-list").addClass("slidr-wall");
        for(i = 0;i<g_wall.data.length  && g_wall.data[i].image;i++){
          imgs[i].src = g_wall.data[i].image.large;
        }
      }
      //修复切换模式时的margin值
      var top = $(this).position().top;
      if(!$("#wall-list").hasClass("slidr-wall") && $("#wall-list").children().length>2){
        top = top-$(this).height()-10;
      }
      $("#wall-list").css({
        'margin-top':'-'+top+'px'
      });
      //end delegate
    });
  },
  //自动轮播
  autoplayWall:function(time){
    g_wall.autoplayTimer = setInterval(function(){
      g_wall.playNext();
    },time);
    g_wall.isPlaying = true;
  },
  //停止自动播放
  stopAutoplay:function(){
    clearInterval(g_wall.autoplayTimer);
    g_wall.isPlaying = false;
  },
  //查看下一条消息
  playNext:function(){
    if( $("#wall-list").height() < $("#main").height() ){
      $("#wall-list").css({"margin-top":"0"});
      return ;
    }
    var totalNum = $("#wall-list").children().length;
    var singleHeight = $("#wall-list li").height()+10;
    var marginTop = -$("#wall-list").css("margin-top").replace("px","");

    if(marginTop < totalNum*singleHeight){
      marginTop += singleHeight;
      $("#wall-list").animate({
        'margin-top':'-'+marginTop+'px'
      },1000);
    }
    else{
      $("#wall-list").css({"margin-top":$("#wall-list").height()+"px"});
      $("#wall-list").animate({
        'margin-top':'0px'
      },1000);
    }
  },
  //查看上一条消息
  playBack:function(){
    if( $("#wall-list").height() < $("#main").height() )return;
      var totalNum = $("#wall-list").children().length;
      var singleHeight = $("#wall-list li").height()+10;
      var marginTop = -$("#wall-list").css("margin-top").replace("px","");

      if(marginTop < totalNum*singleHeight){
        marginTop -= singleHeight;
        $("#wall-list").animate({
          'margin-top':'-'+marginTop+'px'
        },1000);
      }
      else{
        $("#wall-list").animate({
          'margin-top':'0px'
        },1000);
      }
  },
  getData:function(){
    $.ajax({
      url:"/api/wall_feeds",
      data:{
        'eventid':getCookieVal("id")
      },
      type:"get",
      dataType:"json",
      success:function(data){
        g_wall.data = data;
        g_wall.addUsers2Wall(g_wall.data);
      },
      error:function(data){
        alert("网络错误，请联系管理员");
      }
    });
  },
  initkeyEvent:function(){
    $(document).keypress(function(e){
      // alert(e.keyCode)
      switch(e.keyCode){
        case 37://left
          g_wall.playBack();
          break;
        case 39://right
          g_wall.playNext();
          break;
        case 38://up
          g_wall.playBack();
          break;
        case 40://down
          g_wall.playNext();
          break;
        case 32://space 暂停/开始
          if(g_wall.isPlaying){
            g_wall.stopAutoplay();
            $("#menu .btn-begin").removeClass("btn-begin").addClass("btn-pause");
            // console.log("pause")
          }
          else{
            g_wall.autoplayWall(g_wall.slideDurationTime);
            $("#menu .btn-pause").removeClass("btn-pause").addClass("btn-begin");
          }
          break;
        default:
          console.log(e.keyCode)
          break;
      };
    });
  },
  initBtnEvent:function(){
    $("#menu .btn-func-container").delegate("a","click",function(e){
      e.preventDefault();
      var cls=$(this).attr("class");
      if(cls == "btn-func btn-old"){
        $("#wall-list").animate({
          'margin-top':'0px'
        },500);
      }
      else if(cls == "btn-func btn-prev"){
        g_wall.playBack();
      }
      else if(cls == "btn-func btn-begin"){
        g_wall.stopAutoplay();
        $("#menu .btn-begin").removeClass("btn-begin").addClass("btn-pause");
      }
      else if(cls == "btn-func btn-pause"){
        g_wall.autoplayWall(g_wall.slideDurationTime);
        $("#menu .btn-pause").removeClass("btn-pause").addClass("btn-begin");
      }
      else if(cls == "btn-func btn-next"){
        g_wall.playNext();
      }
      else if(cls == "btn-func btn-new"){
        var h=$("#wall-list").height()-$("#wall-list li").height()-10;
        $("#wall-list").animate({
          'margin-top':-h+'px'
        },500);
      }
      else{

      }
    });
  },
  init:function(){
    g_wall.getData();
    setInterval(g_wall.getData,3000);//定时向服务端获取评论信息
    g_wall.changeWallMode();
    g_wall.autoplayWall(g_wall.slideDurationTime);
    g_wall.initkeyEvent();
    g_wall.initBtnEvent();
  }
  //WALL object end
}; 

