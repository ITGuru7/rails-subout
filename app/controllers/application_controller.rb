class ApplicationController < ActionController::Base
  before_filter :check_uri
  before_filter :https_redirect

  private

  def check_uri
    redirect_to "https://www.suboutapp.com#{request.fullpath}" if "suboutapp.com" == request.host
  end

  def https_redirect
    if ENV["ENABLE_HTTPS"]
      if !request.ssl?
        flash.keep
        redirect_to protocol: "https://", status: :moved_permanently
      end
    end
  end
end
