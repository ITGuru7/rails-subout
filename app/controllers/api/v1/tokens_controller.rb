class Api::V1::TokensController < Api::V1::BaseController
  skip_before_filter :restrict_access

  def create
    username = params[:email].downcase if params[:email]
    if user = User.where(:email => username).first
      if user.access_locked?
        render :json => { authorized: false, message: "Your account is locked. Please contact admin."}
      elsif user.valid_password?(params[:password])
        render json: user.auth_token_hash
        user.update_tracked_fields!(request)
      else
        render :json => { authorized: false, message: "Invalid username or password!"}
      end
    else
      render :json => { authorized: false, message: "Invalid username or password!"}
    end
  end
end
