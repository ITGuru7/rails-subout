class Api::V1::OpportunitiesController < Api::V1::BaseController
  def index
    params[:page] ||= 1
    opportunities = current_company.available_opportunities(params[:sort_by], params[:sort_direction], params[:start_date])
    meta = {
      :opportunities_count =>  opportunities.count,
      :opportunities_per_page => Opportunity.default_per_page,
      :opportunities_page => params[:page].to_i,
    }
    #render json: result
    render json: opportunities.page(params[:page]), root: "opportunities", meta: meta
  end

  def show
    @opportunity = Opportunity.where('$or' => [{:id => params[:id]}, {:reference_number => params[:id]}]).first
    @opportunity.viewer = current_company

    respond_with_namespace(@opportunity)
  end
end
