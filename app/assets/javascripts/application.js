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
//= require jquery-ui-1.8.9.custom.min
//= require jquery.timeentry
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
	mm_page.handleActions();
}

mm_page.handleActions = function()
{
		$.address.init(function(event){}).change(function(event) {
			var fx = event.path.replace('-', '_').replace('/','_');
			var init = mm_page.actions[fx];
			if ($.isFunction(init))
				init();
		});	
}

mm_page.actions = {};
/* New opportunity menu click action */
mm_page.actions._new_opportunity = function()
{
	if($('#page_new_opportunity').html()!=""){
			$('#page_new_opportunity').modal();
			return;
	}
	
	mm_opportunity.form(function(html){
		
		$('#page_new_opportunity').html(html);
		mm_opportunity.init_form();
		$('#page_new_opportunity').modal();
		$('#page_new_opportunity').on('hidden', function () {
		  $.address.path('/');
		})
		
	});
	
}

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


$(function () {
	mm_page.init();
	mm_dashboard.init();
})
