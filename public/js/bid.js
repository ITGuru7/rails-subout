var mm_bid = {
	get: function(id, handler)
	{
		$.ajax({
			type : "GET",
			url : mm_application.api_path + "/bids/"+ id +".json",
			data : { auth_token: mm_token.data.auth_token },
			dataType : "jsonp",
			success : function (data) {
				handler(data);
			}, 
			error : function (e) {
				handler();
			}
		});
	}
}