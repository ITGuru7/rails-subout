var mm_event = {};

mm_event.get = function (id, handler) {

}

mm_event.all = function (handler) {
	$.ajax({
		type : "GET",
		url : "/events.json",
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