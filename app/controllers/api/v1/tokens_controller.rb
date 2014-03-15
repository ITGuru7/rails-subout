class Api::V1::TokensController < Api::V1::BaseController
  skip_before_filter :restrict_access

  def create
    username = params[:email].downcase if params[:email]
    if user = User.where(:email => username).first
      subscription = user.company.created_from_subscription
      if user.access_locked?
        render :json => { authorized: false, message: "Your account is locked. Please contact admin."}
      elsif (Rails.env.production? and subscription.is_canceled?) 
        render :json => { authorized: false, message: "You could not sign in. Please contact admin."}
      elsif user.valid_password?(params[:password])
        if params[:deviceToken]
          key = params[:deviceToken]
          device_type = params[:deviceType]

          user.mobile_keys.find_or_create_by(key: key, device_type: device_type)
        end

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
