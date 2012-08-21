mm_application.page = {
	name: "Sign In",
	init: function(){
		mm_company.get(mm_application.page.dashboard.loadCompany);
		mm_event.all(mm_application.page.dashboard.loadEvents);
	},
	
	dashboard:{
		loadCompany: function(data)
		{
			if(data){ 
				$('#page_dashboard #company #company_name').html(data.name); 
			}
		},
		
		builders:{
			opportunity: function(item){
				var html = $("<div></div>").addClass('well row-fluid');
				var col1 = $("<div></div>").html(item.description).addClass('span4 col1');
				var col2 = $("<div></div>").html(item.model_type).addClass('span4 col2');
				html.append(col1).append(col2);
				return html;
			},
			bid: function(item){},
			event: function(item){
				var html = $("<div></div>").addClass('well row-fluid');
				var col1 = $("<div></div>").html(item.model_type + '<br/>' + item.description).addClass('span4 col1');
				html.append(col1);
				return html;
			},
		},
		loadEvents: function(data)
		{
			if(data){ 
				$(data).each(function(idx, item){			
					if(item.company_id==mm_token.data.company_id){
						var fx = item.model_type;
						var init = mm_application.page.dashboard.builders[fx];
						if ($.isFunction(init))
						{	
							$('#page_dashboard #activity .content').append(init(item));
						}
					}
				});
			}
		},
	}
}