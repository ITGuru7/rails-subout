class Api::V1::TokensController < ApplicationController
  skip_before_filter :verify_authenticity_token
  skip_before_filter :authenticate_user!

  respond_to :json

  def create
    user = User.where(:email => params[:email]).first    
    if user && user.valid_password?(params[:password])
      render :json => { api_token: user.authentication_token, authorized: 'true', company_id: user.company_id }
    else      
      render :json => { authorized: 'false' }
    end 
  end 
end
