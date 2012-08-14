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
//= require jquery.address-1.4
  
var mm_default = {
	appendLoadingImg : function (selector) {
		if($('.loading', selector).length==0)
			$(selector).append('<div class="loading"><img class="loading_gif" src="/img/loading.gif" height="24" width="24" /></div>');
	},
	
	removeLoadingImg : function () {
		$('.loading').remove();
	},
	
	init: function(){
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
		
		/** load login form **/
		mm_user.buildLoginForm('#header_b');
	},
}

var mm_user = {
	auth_token : null,
	login : function (email, password) {
		//suboutdev@gmail.com sub0utd3v 
		$.ajax({
			type : "GET",
			url : "/api_login.json",
			data : {
				'email' : email,
				'password' : password
			},
			dataType : "json",
			success : function (data) {
				mm_user.auth_token = data.auth_token;
				mm_nav.build('#header_b');
			},
			error : function (e) {
				
			}
		});
	},
	buildLoginForm:function(container)
	{
		$.ajax({
			type : "GET",
			url : "/partial/loginform.html",
			dataType : "html",
			success : function (data) {
				$(container).html(data);
				mm_user.initLoginForm();
			},
			error : function (e) {
				alert(e);
			}
		});
	},
	
	initLoginForm: function()
	{
		$('#form_login').bind('submit', function(){
			mm_user.login($('#input_email').val(), $('#input_password').val());
			return false;
		});	
	}
	
}

var mm_nav = {
	items : {
		'new_oppotunity' : {
			href : '/new-oppotunity',
			text : 'New Oppotunity',
		},
		'settings' : {
			href : '/settings',
			text : 'Settings',
		},
		'help' : {
			href : '/help',
			text : 'Help',
		},
		'signout' : {
			href : '/signout',
			text : 'Sign Out',
		},
	},
	
	build : function (container) {
		
		var nav = $('<nav></nav>');
		$.each(mm_nav.items, function (id, item) {
			$(nav).append($('<a>' + item.text + '</a>').attr('href', item.href).addClass('address'));
		});
		
		$(':last', nav).addClass('last');
		$(container).html(nav);	
	}
};


$(function () {
	mm_default.init();
	

	$.address.init(function(event){}).change(function(event) {
		switch(event.path){
			case '/new-oppotunity':
			case '/settings':
			case '/help':
			case '/signout':
		}
	});
})
