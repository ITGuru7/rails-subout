$.fn.center = function () {
    this.css("position","absolute");
	this.css({
			top: ( $(window).height() - this.height() ) / 2 + $(window).scrollTop() + "px"
			});
    return this;
}

var mm_default = {
	appendLoadingImg : function (selector) {
		$(selector).html('<div class="loading"><img src="/img/loading.gif" height="24" width="24" /></div>');
	},
	
	removeLoadingImg : function () {
		$('.loading').remove();
	},
	
	markLastChild : function (container) {
		$(':last', $(container)).addClass('last');
	},
	getScripts: function (scripts, onComplete)	{
		var i = 1;
		var j = scripts.length;
		var onScriptLoad = function(data, response){
			if(i++ == j) onComplete();
		};
		
		for(var s in scripts)
		{
			$.getScript(scripts[s], onScriptLoad);
		}
	},
	serializeObject : function(form)
	{
		var o = {};
		var a = $(form).serializeArray();
		$.each(a, function() {
			if (o[this.name] !== undefined) {
				if (!o[this.name].push) {
					o[this.name] = [o[this.name]];
				}
				o[this.name].push(this.value || '');
			} else {
				o[this.name] = this.value || '';
			}
		});
		return o;
	},
	
	createButton : function(label)
	{
		var button = $("<a></a>").addClass("btn address").html(label);
		return button;
		
	},
	
	createLabel : function(label)
	{
		return $("<span></span>").addClass("label label-info").html(label);
	},
	
	initAddress: function()
	{
		/** jquery address plugin setting **/
		$('a.address').address(function () {
			return $(this).attr('href');
		});
	}
	
};

var mm_navigator = {
	items : {
		'new_opportunity' : {
			href : '/opportunity-new',
			text : 'New Opportunity',
			visible : 0,
		},
		'dashboard' : {
			href : '/dashboard',
			text : 'Dash board',
			visible : 0,
		},
		'settings' : {
			href : '/settings',
			text : 'Settings',
			visible : 0,
		},
		'help' : {
			href : '/help',
			text : 'Help',
			visible : 1,
		},
		'signout' : {
			href : '/signout',
			text : 'Sign Out',
			visible : 0,
		},
		'signin' : {
			href : '/signin',
			text : 'Sign In',
			visible : 1,
		},
	},
	
	build : function (container) {
		var items = mm_navigator.items;
		$(container).html("");
		if(mm_token.data.auth_token)
		{
			items.signout.visible = 1;
			items.signin.visible = 0;
			items.settings.visible = 1;
			items.new_opportunity.visible = 1;
			items.dashboard.visible = 1;
		}else{
			items.signout.visible = 0;
			items.signin.visible = 1;
		}
		
		$.each(items, function (id, item) {
			if (item.visible) {
				$(container).append($('<a>' + item.text + '</a>').attr('href', item.href).addClass('address'));
			}
		});
		$(':last', $(container)).addClass('last');
		
		/** jquery address plugin setting **/
		$('a.address').address(function () {
			return $(this).attr('href');
		});
	
		return $(container);
	}
};


var pubnub  = PUBNUB({
				publish_key   : 'pub-bc2f574a-db24-436a-abb7-9b8976d67d83',
				subscribe_key : 'sub-fd809ee8-d663-11e1-bf41-5deea89e8e90',
				ssl           : false,
				origin        : 'pubsub.pubnub.com'
			});
			
var mm_application = {
	//api_path: "http://suboutdev.herokuapp.com",
	api_path: "",
	page: null,
};

mm_token = {
	data: {
		auth_token: null,
		company_id: null,
	},
	check: function(){
		
		if(mm_token.data.company_id==null)
		{
			$.address.path('/signin');
			return;
		}
		
		var tid = setTimeout('mm_token.remove();', 5000);
		mm_company.get(mm_token.data.company_id, function(data){
			if(data){
				clearTimeout(tid); 
				mm_company.data = data; 
				mm_token.set(mm_token.data.auth_token, mm_token.data.company_id); 
				
			}else{
				mm_token.remove(); 
			}
		});
	},
	set: function(token, company)
	{
		mm_token.data.auth_token = token;
		mm_token.data.company_id = company;	
		$.cookie('mm_token.auth_token', mm_token.data.auth_token);
		$.cookie('mm_token.company_id', mm_token.data.company_id);
		$.address.path('/dashboard');
	},
	get: function (email, password) {
		//suboutdev@gmail.com sub0utd3v 
		$.ajax({
			type : "GET",
			url : mm_application.api_path + "/api_login.json",
			data : {
				'email' : email,
				'password' : password
			},
			dataType : "jsonp",
			success : function (data) {
				if(data){
					mm_token.set(data.auth_token, data.company._id);
					mm_company.data = data.company; 
					$.address.path('/dashboard');
				}
			},
			error : function (e) {
				alert('Error')
			}
		});
	},
	load: function()
	{
		mm_token.data.auth_token = $.cookie('mm_token.auth_token');
		mm_token.data.company_id = $.cookie('mm_token.company_id');
		mm_token.check();
	},
	remove: function()
	{
		mm_token.data.auth_token = null;
		mm_token.data.company_id = null;
		mm_default.removeLoadingImg();
		$.removeCookie('mm_token.auth_token');
		$.removeCookie('mm_token.company_id');
		$.address.path('/signin');
	}
}

mm_application.init = function () {
	
	$.ajaxSetup({
		beforeSend : function (jqXHR, settings) {
			mm_default.appendLoadingImg($('#loading'));
		},
		complete : function () {
			mm_default.removeLoadingImg();
		}
	});
	mm_token.load();
	mm_navigator.build('header nav');	
	mm_application.actions.handler($.address.path());
	$.address.init(function (event){}).change(function (event) {
		mm_application.actions.handler(event.path);
	});
};

mm_application.actions = {};

mm_application.actions.handler = function(path){ 
	var fx = path.replace(new RegExp(/(-)|(\/)/g), '_');
	var init = mm_application.actions[fx];
	if ($.isFunction(init))
	{
		init();
	}else{
		mm_application.actions['_default']();
	}
}

mm_application.actions._default = function(){
	//mm_application.openPage('index');
};

mm_application.actions._signin = function () {
	mm_application.openPage('signin');
}

mm_application.actions._signout = function () {
	mm_token.remove();
	$.address.path('/signin');
}

mm_application.actions._dashboard = function () {
	mm_application.openPage('dashboard');
}

mm_application.actions._opportunity_new = function () {
	mm_application.openPage('opportunity_new', '#pageModal');
}

mm_application.actions._opportunity_view = function () {
	mm_application.openPage('opportunity_view', '#pageModal');
}

mm_application.actions._opportunity_bid = function () {
	mm_application.openPage('opportunity_bid', '#pageModal');
}

mm_application.actions._bids_view = function () {
	mm_application.openPage('bids_view', '#pageModal');
}


mm_application.openPage = function (page, container) {
	
	if(!container){container = $('#content');}
	var html_url = '/page/'+page + '.html';
	var js_url = '/page/'+page + '.js';
	
	$.ajax({
		type : "GET",
		url : html_url,
		data : {},
		dataType : "html",
		success : function (html) {
			
			$(container).html(html);
			$.getScript(js_url, function(){ mm_application.page.init(); });
			mm_navigator.build('header nav');
		},
		error : function (e) {
			$(container).html("Error: Couldn't load page." + page);
		}});
};

$(function () {
	mm_default.getScripts(['/js/company.js', '/js/event.js', '/js/opportunity.js', '/js/bid.js'], function(){
		mm_application.init();
	});
});
