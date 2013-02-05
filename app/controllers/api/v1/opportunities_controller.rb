class Api::V1::OpportunitiesController < Api::V1::BaseController
  def index
    opportunities = current_company.available_opportunities(params[:sort_by], params[:sort_direction])
    respond_with_namespace(opportunities)
  end

  def show
    @opportunity = Opportunity.where('$or' => [{:id => params[:id]}, {:reference_number => params[:id]}]).first
    @opportunity.viewer = current_company

    respond_with_namespace(@opportunity)
  end
end
