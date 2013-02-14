class Api::V1::BaseController < ActionController::Base
  respond_to :json

  before_filter :restrict_access

  unless Rails.application.config.consider_all_requests_local
    rescue_from Mongoid::Errors::DocumentNotFound, :with => :render_404
  end

  private

  def restrict_access
    return if params[:api_token] and current_user

    head :unauthorized
  end

  def current_user
    @current_user ||= User.find_by(authentication_token: params[:api_token])
  end

  def current_company
    current_user.company
  end

  def render_404
    render :json => {:error => "not-found"}.to_json, :status => 404
  end

  def respond_with_namespace(*resource)
    respond_with(:api, :v1, *resource)
  end
end
