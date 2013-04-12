class Admin::SettingsController < Admin::BaseController
  before_filter :load_setting, only: [:edit, :update]

  def edit
    @setting = Setting.create(key: params[:id]) unless @setting.present?
  end

  def update
    @setting.update_attributes(params[:setting])
    redirect_to edit_admin_setting_path(@setting)
  end

  private

  def load_setting
    @setting = Setting.find_by(key: params[:id])
  end
end
