class Api::V1::TokensController < Api::V1::BaseController
  def create
    user = User.where(:email => params[:email]).first
    if user && user.valid_password?(params[:password])
      render :json => {
        api_token: user.authentication_token,
        authorized: true,
        company_id: user.company_id,
        user_id: user._id,
        pusher_key: Pusher.key
      }
    else
      render :json => { authorized: false }
    end
  end
end
