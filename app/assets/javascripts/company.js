var mm_company = {};

mm_company.login = function (email, password) {
	//suboutdev@gmail.com sub0utd3v 
	$.ajax({
		type : "GET",
		url : "/api_login.json",
		data : {
			'email' : email,
			'password' : password
		},
		dataType : "json",
		success : function (data) {
			mm_company.auth_token = data.auth_token;
			mm_company.company_id = data.company_id;
		},
		error : function (e) {
			
		}
	});
}

mm_company.get = function (handler) {
	$.ajax({
		type : "GET",
		url : "/companies/"+ mm_company.company_id +".json",
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