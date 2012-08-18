var mm_dashboard = {
	init: function(){
		mm_company.get(mm_dashboard.loadCompany);
		//mm_company.events(mm_dashboard.loadEvents);
	},
	loadCompany: function(data)
	{
		if(data){ 
			$('#dashboard #company #company_name').html(data.name); 
		}
	},
	loadEvents: function(data)
	{
		if(data){ 
			$(data).each(function(idx, item){			
				if(item.company_id==mm_company.company_id){
					var fx = 'event';
					var init = mm_dashboard.builders[fx];
					if ($.isFunction(init))
					{	
						$('#dashboard #activity .content').append(init(item));
					}
				}
			});
		}
	},
	builders:{
		opportunity: function(item){
			var html = $("<div></div>").addClass('well row-fluid');
			var col1 = $("<div></div>").html(item.name + '<br/>' + item.start_date).addClass('span4 col1');
			var col2 = $("<div></div>").html(item.description).addClass('span4 col2');
			var col3 = $("<div></div>").html("Current Bid:" + item.buy_it_now_price + '<br/> Expires in ' + item.bidding_ends).addClass('span4 col2');
			html.append(col1).append(col2).append(col3);
			return html;
		},
		bid: function(item){},
		event: function(item){
			var html = $("<div></div>").addClass('well row-fluid');
			var col1 = $("<div></div>").html(item.model_type + '<br/>' + item.description).addClass('span4 col1');
			html.append(col1);
			return html;
		},
	}
};