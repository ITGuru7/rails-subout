class Admin::CompaniesController < Admin::BaseController
  before_filter :load_company, only: [:edit, :cancel_subscription, :add_as_a_favorite]

  def index
    @sort_by = params[:sort_by] || "created_at"
    @sort_direction = params[:sort_direction] || "desc"
    @companies = Company.sort(@sort_by, @sort_direction)

    respond_to do |format|
      format.html
      format.csv { send_data @companies.to_csv }
    end
  end

  def edit
    @subscription = @company.created_from_subscription
  end

  def cancel_subscription
    if subscription = @company.created_from_subscription
      subscription.update_product_and_regions!(product_handle: "state-by-state-service", regions: [])
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
