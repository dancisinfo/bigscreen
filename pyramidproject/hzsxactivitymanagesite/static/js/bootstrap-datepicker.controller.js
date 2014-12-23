	$(function(){
		var starttimepicker = $("#starttime").datepicker({
	    	startView: 1,
		    todayBtn: "linked",
		    language: "zh-CN",
		    autoclose: true,
		    minViewMode: 0,
	    }).on('hide',function(ev){
	    	var startdates = ev.dates;
	    	if(startdates instanceof Array && startdates.length>0){
			    var TimeZoned = new Date(startdates[0]);
			    var starttime = TimeZoned.getTime();
			    var enddates = endpicker.datepicker('getDates');
			    if(enddates instanceof Array && enddates.length>0){
			    	var endtime = new Date(enddates[0]).getTime();
			    	if(starttime>=endtime){
			    		endtime = starttime + 1000*60*60*24;
			    		
			    		SetEnd(endtime);
			    	}
			    }
			    $("input[name='starttime']").val(starttime);
		    }
		});
		var endpicker = $("#endtime").datepicker({
			startView: 1,
		    todayBtn: "linked",
		    language: "zh-CN",
		    autoclose: true,
		    minViewMode: 0,
		}).on('hide',function(ev){
		    if(ev.dates.length>0){
			    var TimeZoned = new Date(ev.dates[0]);
			    $("input[name='endtime']").val(TimeZoned.getTime());
		    }
		    var enddates = ev.dates;
	    	if(enddates instanceof Array && enddates.length>0){
			    var TimeZoned = new Date(enddates[0]);
			    var endtime = TimeZoned.getTime();
			    var startdates = starttimepicker.datepicker('getDates');
			    if(startdates instanceof Array && startdates.length>0){
			    	var starttime = new Date(startdates[0]).getTime();
			    	if(starttime>=endtime){
			    		starttime=endtime - 1000*60*60*24;
			    		SetStart(starttime);
			    	}
			    }
			    $("input[name='starttime']").val(starttime);
		    }
		});
		
		function SetStart(dl){
			if(dl!=""){
				starttimepicker.datepicker('update', new Date( parseInt(dl)));
			}
		}
		function SetEnd(dl){
			if(dl!=""){
				endpicker.datepicker('update', new Date( parseInt(dl)));
			}
		}
				
		SetStart($("input[name='starttime']").val())
		SetEnd($("input[name='endtime']").val())
	})