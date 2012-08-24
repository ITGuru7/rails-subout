mm_application.page = {
	name: "Create New Opportunity",
	init: function(){
			$('#page_new_opportunity').modal();
			$('#page_new_opportunity').on('hidden', function () {
				$.address.path('/dashboard');
			});

			$('.time').timeEntry({spinnerImage: '/img/spinnerDefault.png', spinnerSize: [20, 20, 0]});
			$('.day').datepicker({ changeMonth: true, changeYear: true, showOtherMonths: true, dateFormat: 'yy-mm-dd' }, "disabled");
			
			$('#page_new_opportunity form').submit(function(){
				$('#opportunity_start_date').val($('#opportunity_start_date_day').val() + " " + $('#opportunity_start_date_time').val());
				$('#opportunity_end_date').val($('#opportunity_end_date_day').val() + " " + $('#opportunity_end_date_time').val());
				
				$('.error').removeClass('error');
				var params = mm_default.serializeObject($(this));
				mm_opportunity.save(	
					params, 
					function(data){ 
						$("#message").html('New opportunity is created successfully.').addClass('alert alert-success');
					}, 
					function(error){ 
						
						$.each(error, function(k, v){
								$('input[name="opportunity['+k+']"]').parents('.control-group').addClass('error');
						});
						
						$("#message").html('Please fill out the form.').addClass('alert alert-error');
					} 
				);
				return false;
			});
	}
}