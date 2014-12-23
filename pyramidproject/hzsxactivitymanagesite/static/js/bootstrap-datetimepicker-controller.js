//本地化datetimepicker
(function($){
$.fn.datetimepicker.dates['zh-CN'] = {
      days: ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六", "星期日"],
      daysShort: ["周日", "周一", "周二", "周三", "周四", "周五", "周六", "周日"],
      daysMin:  ["日", "一", "二", "三", "四", "五", "六", "日"],
      months: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"],
      monthsShort:["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"],
      today: "今日",
      suffix: [],
      meridiem: ["上午", "下午"]
  };
}(jQuery));
//实例化datetimepicker
$(document).ready(function(){
  $("#alarm-starttime").datetimepicker({
        language:  'zh-CN',
        format: "yyyy-MM-dd hh:ii:ss",
        autoclose: true,
        todayBtn: true,
        minuteStep: 10
    });
    $("#alarm-endtime").datetimepicker({
        language:  'zh-CN',
        format: "yyyy-MM-dd hh:ii:ss",
        autoclose: true,
        todayBtn: true,
        minuteStep: 10
    });
  $('#alarm-starttime').datetimepicker().on('hide',function(ev){
    var TimeZoned = new Date(ev.date.setTime(ev.date.getTime() + (ev.date.getTimezoneOffset() * 60000)));
    $("input[name='alarm.starttime']").val(TimeZoned.getTime());
  });
  $('#alarm-endtime').datetimepicker().on('hide',function(ev){
    var TimeZoned = new Date(ev.date.setTime(ev.date.getTime() + (ev.date.getTimezoneOffset() * 60000)));
    $("input[name='alarm.endtime']").val(TimeZoned.getTime());
  });
});
