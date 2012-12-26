class Api::V1::AuctionsController < Api::V1::BaseController
  def index
    @auctions = current_company.auctions.active
    respond_with_namespace(@auctions)
  end

  def create
    @auction = Opportunity.new(params[:opportunity])
    @auction.buyer = current_company

    @auction.save

    respond_with_namespace(@auction)
  end

  def update
    @auction = current_company.auctions.find(params[:id])

    if @auction.editable?
      @auction.update!(params[:opportunity])
      respond_with_namespace(@auction)
    else
      render json: { error: "The opportunity is not editable." }, status: :unprocessable_entity
    end
  end

  def show
    @auction = current_company.auctions.find(params[:id])
    respond_with_namespace(@auction)
  end

  # TODO: if it canceled, return error
  def select_winner
    @auction = current_company.auctions.find(params[:id])
    @auction.win!(params[:bid_id])

    head :ok
  end

  # TODO: if it not cancelable return error
  def cancel
    @auction = Opportunity.find(params[:id])
    @auction.cancel!
    head :ok
  end
end
