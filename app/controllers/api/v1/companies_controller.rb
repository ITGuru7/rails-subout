class Api::V1::CompaniesController < Api::V1::BaseController
  def show
    @company = Company.find(params[:id])
    respond_with_namespace(@company)
  end

  def search
    @company = Company.find_by(email: params[:email])
    respond_with_namespace(@company)
  end

  def update
    company = Company.find(params[:id])
    company.update_attributes(params[:company])
    respond_with_namespace(company)
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
