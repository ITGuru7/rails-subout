class Api::V1::CompaniesController < Api::V1::BaseController
  skip_before_filter :restrict_access, only: :create

  def index
    render json: Company.all, each_serializer: ActorSerializer
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
    current_company.update_attributes(params[:company])
    respond_with_namespace(current_company)
  end

  def create
    company = Company.new(params[:company])
    company.prelaunch = true
    if company.save
      respond_with_namespace(company)
    else
      render json: { errors: company.errors.full_messages }, status: 422
    end
  end
end
