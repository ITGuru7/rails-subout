class Api::V1::CompaniesController < Api::V1::BaseController
  skip_before_filter :restrict_access, only: :create

  def index
    companies = Company.companies_for(current_company)
    render json: companies, each_serializer: ActorSerializer
  end

  def show
    @company = Company.find(params[:id])
    respond_with_namespace(@company)
  end

  def search
    @company = Company.find_by(email: params[:email])
    respond_with_namespace(@company)
  end

  def update
    params[:company]["favoriting_buyer_ids"] ||= []
    current_company.update_attributes(params[:company])
    respond_with_namespace(current_company)
  end

  def create
    company = Company.new(params[:company])
    company.created_from_subscription_id = params[:company]["gateway_subscription_id"]
    company.prelaunch = false
    if company.save
      respond_with_namespace(company)
    else
      render json: { errors: company.errors.full_messages }, status: 422
    end
  end

  def update_regions
    if current_company.update_regions!(params[:company][:regions])
      Notifier.delay.updated_licensed_regions(current_company.id)
      render json: {}
    else
      render json: { errors: current_company.errors.full_messages }, status: 422
    end
  end

  def update_product
    if current_company.update_product!(params[:product])
      Notifier.delay.updated_product(current_company.id)
      render json: {}
    else
      render json: { errors: current_company.errors.full_messages }, status: 423
    end
  end
end
