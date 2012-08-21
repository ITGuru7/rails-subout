var mm_opportunity = {};
mm_opportunity.all = function (handler) {
	$.ajax({
		type : "GET",
		url : mm_application.api_path + "/opportunities.json?auth_token=" + mm_token.data.auth_token,
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
mm_opportunity.save = function(params, handler){
	
	$.ajax({
		type : "POST",
		url : mm_application.api_path + "/opportunities.json?auth_token=" + mm_token.data.auth_token,
		data : params,
		dataType : "html",
		success : function (data) {
			handler(data);
		},
		error : function (e) {
			handler();
		},
	});
}