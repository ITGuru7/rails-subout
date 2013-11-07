class Admin::SettingsController < Admin::BaseController
  before_filter :load_setting, only: [:edit, :update]

  def edit
  end

  def update
    @setting.update_attributes(params[:setting])
    redirect_to admin_settings_path, notice: "#{@setting} was updated successfully."
  end

  private

  def load_setting
    @setting = Setting.find(params[:id])
  end
end
