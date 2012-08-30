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
				var html = $("<div></div>").addClass('well row-fluid opportunity');
				var col_desc = $("<div></div>").html(item.description).addClass('span6 col1');
				var col_model = $("<div></div>").addClass('span4 col2');
				
				col_model.html(mm_default.createLabel(item.model_type));
				
				var btn_action = mm_default.createButton("View").addClass("btn btn-primary address");
				
				if(item.company_id==mm_company.data._id+1)
				{
					$(btn_action).attr("href", "/opportunity/view?id=" + item.model_id);
				}else{
					$(btn_action).html('Bid');
					$(btn_action).attr("href", "/opportunity/bid?id=" + item.model_id);
				}
				
				var col_actions = $("<div></div>").html(btn_action).addClass('span2 col3');
				
				html.append(col_desc).append(col_model).append(col_actions);
				return html;
			},
			bid: function(item){
				
			},
			event: function(item){
				var html = $("<div></div>").addClass('well row-fluid');
				var col_desc = $("<div></div>").html(item.description).addClass('span4 col1');
				var col_model = $("<div></div>").html(item.model_type).addClass('span4 col2');
				html.append(col_desc).append(col_model);
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
			mm_application.page.dashboard.loadPubnubEvents();
		},
		
		loadPubnubEvents: function()
		{
			// ----------------------------------------------
			// INIT
			// ----------------------------------------------
			var channel = mm_company.data.company_msg_path;
			log(mm_company.data.company_msg_path);
			// ----------------------------------------------
			// Establish a Connection
			// ----------------------------------------------
			log('Opening a Connection.');
			pubnub.subscribe({
				channel  : channel,
				connect  : ready,
				callback : function(message){
					log('Received a Message.');
					log(message);
					log('Closing Connection');
					var fx = message.model_type;
					var init = mm_application.page.dashboard.builders[fx];
					if ($.isFunction(init))
					{	
						$('#page_dashboard #activity .content').append(init(message));
					}
						
					
				}
			});

			// ----------------------------------------------
			// Connection Is Open Now and Ready
			// ----------------------------------------------
			function ready() {
				log('Connection Established.');
				//send('hello');
			}

			// ----------------------------------------------
			// Send Request Finished with Status
			// ----------------------------------------------
			function log(message) {
				console.log(message);
			}	
		}
	}
}