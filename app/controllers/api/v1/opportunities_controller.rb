class OpportunitiesController < ApplicationController
  def index
    @opportunities = Opportunity.available
  end

  def show
    #NOTE: thinking to use embed resource for bids
    @opportunity = Opportunity.find(params[:id])
  end
end
