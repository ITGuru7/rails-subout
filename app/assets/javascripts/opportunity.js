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
