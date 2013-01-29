class Admin::CompaniesController < Admin::BaseController
  def index
    @companies = Company.recent
  end
end
