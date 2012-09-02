mm_application.page = {
	name: "View Opportunity",
	rows_offset: 0,
	rows_per_page: 10,
	opportunities: null,

	build_table: function(){
		var opportunities = mm_application.page.opportunities;
		if(opportunities){
			for(var i=mm_application.page.rows_offset; i< mm_application.page.rows_offset + mm_application.page.rows_per_page; i++)
			{
				mm_application.page.build_opportunity(opportunities[i]);
			}
		}
	},
	
	build_opportunity: function(opportunity){
			var tr = $("<tr></tr>");
			var td = $("<td></td>");		
			var tr_new = tr.clone();
			var td_opportunity = td.clone().addClass('opportunity').text(opportunity.name);
			var td_source = td.clone().addClass('source').text(" ");
			var td_last = td.clone().addClass('last').text(" ");
			var td_winning_bid = td.clone().addClass('winning_bid').text(opportunity.winning_bid_id + " ");
			var td_expires = td.clone().addClass('expires');
			
			var diff =  Math.floor(( Date.parse(opportunity.end_date) - Date.parse(new Date()) ));
			if(diff/86400000 < 1)
			{
				td_expires.text(Math.ceil(diff/3600*1000) + " hours");	
			}
			
			if(diff/86400000 > 1)
			{
				td_expires.text(Math.ceil(diff/86400000) + " days");	
			}
			
			if(diff/86400000 < 0)
			{
				td_expires.text(-1 * Math.ceil(diff/86400000) + " days ago");	
			}

			tr_new.append(td_opportunity)
			.append(td_opportunity)
			.append(td_source)
			.append(td_last)
			.append(td_winning_bid)
			.append(td_expires);

			$('#bids').append(tr_new);
			var obj = $('#bids tr:last');
			mm_application.page.fill_bids(opportunity, obj);
	},
	
	fill_bids: function(opportunity, obj){
			mm_opportunity.getBids(opportunity._id, function(data){ 
				if(data.length>0){
					$('.last', obj).text(data[0].amount);	
				}
			});
			
			mm_company.get(opportunity.company_id, function(data){ 
				if(data){
					$('.source', obj).text(data.name);	
				}
			});
	},
	
	
	init: function(){
			$('#page_view_bids').modal();
			$('#page_view_bids').on('hidden', function () {
				$.address.path('bids/view/close');
				$.address.queryString('');
			});
			
			mm_company.opportunities(function(opportunities){
				mm_application.page.opportunities = opportunities;
				mm_application.page.build_table();
			});
			
			$("#btn_load_more").click(function(){
				
				mm_application.page.rows_offset = mm_application.page.rows_offset + mm_application.page.rows_per_page;
				if(mm_application.page.rows_offset > mm_application.page.opportunities.length)
				{
					$(this).remove();
				}
				mm_application.page.build_table();
			});
	},
}