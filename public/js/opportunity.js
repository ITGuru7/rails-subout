var mm_opportunity = {};
mm_opportunity.all = function (handler) {
	$.ajax({
		type : "GET",
		url : mm_application.api_path + "/opportunities.json",
		data : {
			auth_token : mm_token.data.auth_token,
		},
		dataType : "jsonp",
		success : function (data) {
			handler(data);
		},
		error : function (e) {
			handler();
		}
	});
}

mm_opportunity.get = function (id, handler) {
	$.ajax({
		type : "GET",
		url : mm_application.api_path + "/opportunities/" + id + ".json",
		data : {
			auth_token : mm_token.data.auth_token,
		},
		dataType : "jsonp",
		success : function (data) {
			handler(data);
		},
		error : function (e) {
			handler();
		}
	});
}

mm_opportunity.save = function (params, handler1, handler2) {
	
	$.ajax({
		type : "POST",
		url : mm_application.api_path + "/opportunities.json?auth_token=" + mm_token.data.auth_token,
		data : params,
		dataType : "jsonp",
		success : function (data) {
			handler1(data);
		},
		error : function (request, status, error) {
			var data = $.parseJSON(request.responseText)
				if (handler2) {
					handler2($.parseJSON(request.responseText));
				}
		},
	});
}
