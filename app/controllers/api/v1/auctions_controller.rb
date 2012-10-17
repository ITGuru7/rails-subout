class Api::V1::AuctionsController < Api::V1::BaseController
  def index
    @auctions = current_company.auctions
    respond_with(@auctions)
  end

  def create
    @auction = Opportunity.new(params[:opportunity])
    @auction.buyer = current_company

    #TODO ask tom if the form should allow selection of type.  For now just going to default this
    @auction.opportunity_type = OpportunityType.where(:name => 'Emergency').first

    @auction.save

    respond_with(@auction)
  end

  def show
    @auction = Opportunity.find(params[:id])
  end

  def select_winner
    @auction = Opportunity.find(params[:id])
    @auction.win!(params[:bid_id])

    redirect_to auction_path(@auction)
  end
end
