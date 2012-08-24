mm_application.page = {
	name: "View Opportunity",
	init: function(){
			$('#page_view_opportunity').modal();
			$('#page_view_opportunity').on('hidden', function () {
				$.address.path('/dashboard');
				$.address.queryString('');
			});
			var opportunity_id = $.address.parameter('id');
			
			mm_opportunity.get(opportunity_id, function(data){ 
				$(".section-title h2").html(data.name);
			});
	}
}