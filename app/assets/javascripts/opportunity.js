var mm_opportunity = {};

mm_opportunity.get = function (id, handler) {

}

mm_opportunity.all = function (handler) {
	$.ajax({
		type : "GET",
		url : "/opportunities.json",
		data : {},
		dataType : "json",
		success : function (data) {
			handler(data);
		},
		error : function (e) {
			handler();
		}
	});
}

mm_opportunity.form = function(handler){
	$.ajax({
		type : "GET",
		url : "/opportunities/new.js",
		data : {},
		dataType : "html",
		success : function (data) {
			handler(data);
		},
		error : function (e) {
			handler();
		}
	});
}

mm_opportunity.save = function(data, handler){
	$.ajax({
		type : "POST",
		url : "/opportunities.js",
		data : {},
		dataType : "html",
		success : function (data) {
			handler(data);
		},
		error : function (e) {
			handler();
		}
	});
}

mm_opportunity.init_form = function(){
	$('.time').timeEntry({spinnerImage:'/assets/spinnerDefault.png'});
	$(".date").datepicker({ changeMonth: true, changeYear: true, showOtherMonths: true, dateFormat: 'yy-mm-dd' }, "disabled");
	
	$('form#new_opportunity').submit(function(){
		return false;
	});
}