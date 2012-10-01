class ApplicationController < ActionController::Base
  before_filter :authenticate_user!
  protect_from_forgery
  
  unless Rails.application.config.consider_all_requests_local
    rescue_from Mongoid::Errors::DocumentNotFound, :with => :render_404
  end 

  helper_method :current_company
  def current_company
    current_user.company
  end


private

  def render_404
    render :template => "errors/404", :status => 404
  end
end
