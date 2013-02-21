class Admin::CompaniesController < Admin::BaseController
  def index
    @sort_by = params[:sort_by] || "created_at"
    @sort_direction = params[:sort_direction] || "desc"
    @companies = Company.sort(@sort_by, @sort_direction)

    respond_to do |format|
      format.html
      format.csv { send_data @companies.to_csv }
    end
  end
end
