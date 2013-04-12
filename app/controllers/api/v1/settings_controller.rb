class Api::V1::SettingsController < Api::V1::BaseController
  skip_before_filter :restrict_access

  def index
    settings = Setting.all
    render json: settings 
  end
  
  def show
    setting = Setting.find_by(key: params[:id])
    render json: setting
  end
end
