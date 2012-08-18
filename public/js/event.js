var mm_event = {};
mm_event.get = function (id, handler) {

}

mm_event.all = function (handler) {
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