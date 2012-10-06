class OpportunitiesController < ApplicationController
  def index
    @opportunities = Opportunity.available
  end

  def show
    #NOTE: thinking to use embed resource for bids
    @opportunity = Opportunity.find(params[:id])
  end
  
  # GET /opportunities/new
  # GET /opportunities/new.json
  def new
    @opportunity = Opportunity.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @opportunity, :callback => params[:callback] }
    end
  end
  
end
