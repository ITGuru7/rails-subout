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
				$("#opportunity_wrapper .section-content #opportunity #description").html(data.description);
				var diff =  Math.floor(( Date.parse(data.end_date) - Date.parse(new Date()) ) / 86400000);
				$("#opportunity_wrapper #expires").text(diff);
				var expires = diff;
				if(diff<0)
				{
					expires = (-1 * diff) + " days ago";
					$('#form_bid').remove();
				}
				
				if(diff==0)
				{
					expires = "Today";
				}
				
				if(diff>0)
				{
					expires = diff + " days";
				}
				
				$("#opportunity_wrapper #winning_bid").text( data.winning_bid_id );
				$("#opportunity_wrapper #expires").text( expires );
			});
			
			mm_opportunity.getBids(opportunity_id, function(data){ 
				var bid_wrapper = $('<div class="row-fluid"><div class="span2"></div></div>');
				var bid = $('<div class="bid span10"></div>');
				
				
				
				$(data).each(function(idx, item){			
					var b = bid.clone();
					var bw = bid_wrapper.clone();
					
					var btn_accept = mm_default.createButton('Accept').attr("href", "/opportunity/accept?oid="+item.opportunity_id+"&bid=" + item._id);
					
					b.html(item.posting_company_id + ", Amount:" + item.amount + " ");
					b.append(btn_accept);
					bw.append(b);
					$("#bids_wrapper #bids").append(bw);
					
				});
				
				$("#bid_count").text(data.length);
				
			});
	}
}