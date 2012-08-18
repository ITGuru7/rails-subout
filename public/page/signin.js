mm_application.page = {
	name: "Sign In",
	init: function(){
	
			$('#page_login form').submit(function(){
				var email = $("#user_email", this).val();
				var password = $("#user_password", this).val();
				mm_token.get(email, password);
				return false;
			});
	},
}