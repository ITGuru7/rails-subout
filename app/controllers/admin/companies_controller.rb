class Admin::CompaniesController < Admin::BaseController
  def index
    @companies = Company.all
  end
end
