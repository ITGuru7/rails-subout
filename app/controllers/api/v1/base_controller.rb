class Api::V1::BaseController < ActionController::Base

  private

  def current_user
    @current_user ||= User.find_by(authentication_token: params[:api_token])
  end

  def current_company
    current_user.company
  end
end
