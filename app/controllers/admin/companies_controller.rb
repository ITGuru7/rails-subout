class Admin::CompaniesController < Admin::BaseController
  before_filter :load_company, only: [:edit, :cancel_subscription, :add_as_a_favorite, :lock_account, :unlock_account, :change_emails]

  def index
    @sort_by = params[:sort_by] || "created_at"
    @sort_direction = params[:sort_direction] || "desc"
    @companies = Company.sort(@sort_by, @sort_direction).includes(:users)

    respond_to do |format|
      format.html
      format.csv { send_data @companies.to_csv }
    end
  end

  def edit
    @subscription = @company.created_from_subscription
  end

  def change_emails
    @company.change_emails!(params[:email])
    redirect_to edit_admin_company_path(@company), notice: 'All emails were updated successfully.'
  end

  def lock_account
    if subscription = @company.created_from_subscription
      subscription.update_product_and_vehicle_count!(product_handle: "free", vehicle_count: 0)
      @company.set_subscription_info
      @company.save
    end

    @company.lock_access!
    redirect_to edit_admin_company_path(@company)
  end

  def unlock_account
    if subscription = @company.created_from_subscription
      subscription.update_product_and_vehicle_count!(product_handle: "subout-basic-service", vehicle_count: 0)
      @company.set_subscription_info
      @company.save
    end
    @company.unlock_access!
    redirect_to edit_admin_company_path(@company)
  end

  def cancel_subscription
    if subscription = @company.created_from_subscription
      subscription.update_product_and_vehicle_count!(product_handle: "free", vehicle_count: 0)
      @company.set_subscription_info
      @company.save
    end
    redirect_to edit_admin_company_path(@company)
  end

  def add_as_a_favorite
    poster = Company.find(params[:company_id])
    poster.add_favorite_supplier!(@company)
    redirect_to edit_admin_company_path(@company)
  end

  private

  def load_company
    @company = Company.find(params[:id])
  end
end
