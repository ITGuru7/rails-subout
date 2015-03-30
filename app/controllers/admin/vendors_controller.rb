class Admin::VendorsController < Admin::BaseController
  before_filter :load_vendor, only: [:edit, :update]

  def index
    @vendors = Vendor.all
  end

  def edit

  end

  def update
    @vendor.update_attributes(params[:vehicle])
  end

  private

  def load_vendor
    @vendor = Vendor.find(params[:id])
  end

  def vendor_params
    params.require(:vendor).permit(:name, :email, :crm_id)
  end
end