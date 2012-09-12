class OpportunitiesController < ApplicationController
  before_filter :authenticate_user!

  def new
    @opportunity = Opportunity.new
  end

  def create
    @opportunity = Opportunity.new(params[:opportunity])
    @opportunity.company = current_user.company

    if @opportunity.save
      redirect_to dashboard_path, :notice => "Opportunity has been created"
    else
      render :new
    end

  end
end
