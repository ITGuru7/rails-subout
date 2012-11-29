class Api::V1::OpportunitiesController < Api::V1::BaseController
  def show
    @opportunity = Opportunity.find(params[:id])
    respond_with_namespace(@opportunity)
  end
end
