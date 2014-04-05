class Api::V1::CompaniesController < Api::V1::BaseController
  skip_before_filter :restrict_access, only: :create
  skip_before_filter :restrict_ghost_user, only: [:create, :update_agreement]
  serialization_scope :current_company

  def index
    companies = Company.companies_for(current_company)
    render json: companies, each_serializer: ActorSerializer
  end

  def show
    @company = Company.find(params[:id])
    @serializer = CompanySerializer.new(@company, :scope => current_company)
    render json: @serializer
  end

  def search
    @companies = Company.search(params[:query]).limit(20)
    render json: @companies
  end

  def update
    company = params[:company].except(:favoriting_buyer_ids, :regions)
    current_company.update_attributes(company)
    respond_with_serializer()
  end

  def create
    chargify_id = params[:company][:chargify_id]
    subscription = nil

    if chargify_id.present?
      subscription = GatewaySubscription.where(subscription_id: chargify_id).first
    end

    company = Company.new(params[:company])

    if subscription.blank?
      company.errors.add(:base, "Invalid chargify subscription.")
    else
      if subscription.created_company.present?
        company.errors.add(:base, "Subscription is already used.")
      end
    end

    if company.errors.any?
      render json: { errors: company.sign_up_errors }, status: 422
      return
    end

    company.created_from_subscription = subscription
    company.prelaunch = false

    if company.save
      respond_with_namespace(company)
    else
      render json: { errors: company.sign_up_errors }, status: 422
    end
  end

  def update_product
    if current_company.update_product!(params[:product])
      Notifier.delay.updated_product(current_company.id) if current_company.notification_items.include?("account-update-product")
      respond_with_serializer()
    else
      render json: { errors: current_company.errors.full_messages }, status: 423
    end
  end

  def update_agreement
    current_company.tac_agreement = true
    current_company.save()
    respond_with_serializer()
  end

  def update_regions
    if current_company.update_regions!(params[:company][:regions])
      respond_with_serializer()
    else
      render json: { errors: current_company.errors.full_messages }, status: 422
    end
  end

  def update_vehicles
    if current_company.update_vehicles!(params[:company][:vehicles])
      respond_with_serializer()
    else
      render json: { errors: current_company.errors.full_messages }, status: 422
    end
  end

  private

  def respond_with_serializer()
    current_company.reload
    @serializer = CompanySerializer.new(current_company, :scope => current_company)
    render json: @serializer
  end
end
