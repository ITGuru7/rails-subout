class OpportunitiesController < ApplicationController
  def index
    @opportunities = Opportunity.available
  end

  def show
    #NOTE: thinking to use embed resource for bids
    @opportunity = Opportunity.find(params[:id])
  end

  #def win_it_now
    #@opportunity = Opportunity.find(params[:id])
    #@opportunity.quick_win_by!(current_company)
  #end
end
