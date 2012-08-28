mm_application.page = {
	name: "View Opportunity",
	init: function(){
			$('#page_view_opportunity').modal();
			$('#page_view_opportunity').on('hidden', function () {
				$.address.path('opportunity/view/close');
				$.address.queryString('');
			});
			var opportunity_id = $.address.parameter('id');
			
			mm_opportunity.get(opportunity_id, function(data){ 
				$("#opportunity_wrapper .section-title h2").html(data.name);
				$("#opportunity_wrapper .section-content #description").html(data.description);
			});
			
			mm_opportunity.getBids(opportunity_id, function(data){ 
				
			});
	}
}