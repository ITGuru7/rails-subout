class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_company
  def current_company
    current_user.company
  end
end
