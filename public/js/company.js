var mm_company = {
	data:{
		_id: null,
		active: false,
		company_msg_path: null,
		hq_location_id: null,
		name: null,
	}
};
mm_company.get = function (handler) {
	$.ajax({
		type : "GET",
		url : mm_application.api_path + "/companies/"+ mm_token.data.company_id +".json?auth_token=" + mm_token.data.auth_token,
		data : {},
		dataType : "jsonp",
		success : function (data) {
			handler(data);
		}, 
		error : function (e) {
			handler();
		}
	});
}

mm_company.events = function (handler) {
	$.ajax({
		type : "GET",
		url : mm_application.api_path + "/companies/events/"+ mm_token.data.company_id +".json?auth_token=" + mm_token.data.auth_token,
		data : {},
		dataType : "jsonp",
		success : function (data) {
			handler(data);
		}, 
		error : function (e) {
			handler();
		}
	});
}