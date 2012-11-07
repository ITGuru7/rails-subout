class Api::V1::AuctionsController < Api::V1::BaseController
  def index
    @auctions = current_company.auctions.active
    respond_with(@auctions)
  end

  def create
    @auction = Opportunity.new(params[:opportunity])
    @auction.buyer = current_company

    @auction.save

    respond_with(@auction)
  end

  def show
    @auction = current_company.auctions.find(params[:id])
    respond_with(@auction)
  end
  
  def select_winner
    @auction = current_company.auctions.find(params[:id])
    @auction.win!(params[:bid_id])

    head :ok
  end

  def cancel
    @auction = Opportunity.find(params[:id])
    @auction.cancel!

    head :ok
  end
end
