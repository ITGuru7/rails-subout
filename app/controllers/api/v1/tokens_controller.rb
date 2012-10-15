class Api::V1::TokensController < Api::V1::BaseController
  def create
    logger.info params
    user = User.where(:email => "suboutdev@gmail.com").first
    if user && user.valid_password?("sub0utd3v")
      render :json => { api_token: user.authentication_token, authorized: 'true', company_id: user.company_id }
    else
      render :json => { authorized: 'false' }
    end
  end
end
