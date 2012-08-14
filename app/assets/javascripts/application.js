// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery.min
//= require jquery_ujs
//= require bootstrap-modal
//= require jquery.address-1.4
//= require company
//= require opportunity

var mm_default = {
	appendLoadingImg : function (selector) {
		$(selector).html('<div class="loading"><img src="/assets/loading.gif" height="24" width="24" /></div>');
	},
	
	removeLoadingImg : function () {
		$('.loading').remove();
	},
	
	markLastChild: function(container)
	{
		$(':last', container).addClass('last');
	}
}


var mm_page = {};
mm_page.init = function()
{
	/** global ajax setting **/
	$.ajaxSetup({
		beforeSend: function (jqXHR, settings) {
			mm_default.appendLoadingImg($('#loading'));
		},
		complete: function(){
			mm_default.removeLoadingImg();
		}
	});
	
	/** jquery address plugin setting **/
	$('a.address').address(function() {  
		return $(this).attr('href');  
	});
	
	mm_default.markLastChild('header nav');
	mm_page.handleAddress();
}

mm_page.handleAddress = function()
{
		$.address.init(function(event){}).change(function(event) {
			var fx = event.path.replace('-', '_').replace('/','');
			var init = mm_page.actions[fx];
			if ($.isFunction(init))
				init();
		});	
}

mm_page.actions = {};
/* New opportunity menu click action */
mm_page.actions.new_opportunity = function()
{
	mm_opportunity.form(function(html){
			$('#page_new_opportunity').html(html);
			$('#page_new_opportunity').modal();
			$('#page_new_opportunity').on('hidden', function () {
			  $.address.state('#');
			})
	});
	
}

var mm_dashboard = {
	init: function(){
		mm_dashboard.loadCompany();
		mm_company.get(mm_dashboard.loadCompany);
		mm_opportunity.all(mm_dashboard.loadOpportunities);
	},
	loadCompany: function(data)
	{
		if(data){ 
			$('#dashboard #company #company_name').html(data.name); 
		}
	},
	loadOpportunities: function(data)
	{
		if(data){ 
			$(data).each(function(idx, item){			
				if(item.company_id==mm_company.company_id){
					var html_item = $("<div></div>").addClass('well row-fluid');
					var html_name = $("<div></div>").html(item.name + '<br/>' + item.start_date).addClass('span4 col1');
					var html_description = $("<div></div>").html(item.description).addClass('span4 col2');
					var html_bid = $("<div></div>").html("Current Bid:" + item.buy_it_now_price + '<br/> Expires in ' + item.bidding_ends).addClass('span4 col2');
					html_item.append(html_name).append(html_description).append(html_bid);
					$('#dashboard #activity .content').append(html_item);
				}
			});
		}
	}
};


$(function () {
	mm_page.init();
	mm_dashboard.init();
})
