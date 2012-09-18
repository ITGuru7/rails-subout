class ApplicationController < ActionController::Base
  before_filter :authenticate_user!
  protect_from_forgery
  

  helper_method :current_company
  def current_company
    current_user.company
  end
end
