class Api::V1::CompaniesController < Api::V1::BaseController
  def show
    @company = Company.find(params[:id])
    respond_with(@company)
  end

  def search
    @company = Company.find_by(email: params[:email])
    respond_with(@company)
  end

  def update
    company = Company.find(params[:id])
    company.update_attributes(params[:company])
    respond_with(company)
  end

  def create
    company = Company.new(params[:company])
    if company.save
      company.created_from_invitation.accept!
    end

    respond_with(company)
  end
end
