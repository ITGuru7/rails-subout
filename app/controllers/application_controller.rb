class ApplicationController < ActionController::Base
  before_filter :https_redirect

  private

  def https_redirect
    if ENV["ENABLE_HTTPS"]
      if !request.ssl?
        flash.keep
        redirect_to protocol: "https://", status: :moved_permanently
      end
    end
  end
end
