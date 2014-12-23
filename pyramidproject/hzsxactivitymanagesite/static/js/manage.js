
function dispatchError(form_errors){
  if(form_errors.title){
    $("#title + .help-block").html(form_errors.title);
    $("#title + .help-block").addClass("help-error");
  }
  else if(form_errors.addr){
    $("#addr + .help-block").html(form_errors.addr);
    $("#addr + .help-block").addClass("help-error");
  }
  else if(form_errors.content){
    $("#myEditor + .help-block").html(form_errors.content);
    $("#myEditor + .help-block").addClass("help-error");
  }
  else{
    for(var key in form_errors){
      $(".help-errors").html("<p>"+key+"格式错误:"+form_errors[key.toString()]+"</p>");
    }
    
  }
}
  
function successReturn(url){
  $(".help-errors").html("<h2>操作成功，正在跳转...</h2>");
  setTimeout(function(){
    window.location.href=url;
  },1000);
}