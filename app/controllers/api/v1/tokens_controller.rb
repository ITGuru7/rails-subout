class Api::V1::TokensController < Api::V1::BaseController
  def create
    user = User.where(:email => params[:email]).first
    if user && user.valid_password?(params[:password]) 
      if user.company.prelaunch?
        render :json => { authorized: false, message: "Thanks for pre-registering but we don't launch until January 8th. Have a great holiday season!"}
      else
        render :json => {
          api_token: user.authentication_token,
          authorized: true,
          company_id: user.company_id,
          user_id: user._id,
          pusher_key: Pusher.key
        }
      end
    else
      render :json => { authorized: false, message: "Invalid username or password!"}
    end
  end
end
