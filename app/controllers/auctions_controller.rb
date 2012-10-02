class AuctionsController < ApplicationController
  def index
    @auctions = current_company.auctions
  end

  def new
    @auction = Opportunity.new
  end

  def create
    @auction = Opportunity.new(params[:opportunity])
    @auction.buyer = current_company

    if @auction.save
      redirect_to dashboard_path, :notice => "The auction has been created"
    else
      render :new
    end

  end
end
