class Api::V1::AuctionsController < Api::V1::BaseController
  def index
    params[:page] ||= 1
    opportunities = current_company.auctions.active.desc(:bidding_ends_at)
    result = {
      :opportunities_count =>  opportunities.count,
      :opportunities_per_page => Opportunity.default_per_page,
      :opportunities_page => params[:page].to_i,
      :opportunities => opportunities.page(params[:page])
    }
    render json: result
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
      render json: { errors: { base: ["This opportunity is not editable."] } }, status: :unprocessable_entity
    end
  end

  def show
    @auction = current_company.auctions.find(params[:id])
    respond_with_namespace(@auction)
  end

  def select_winner
    @auction = current_company.auctions.find(params[:id])
    if @auction.canceled?
      render json: { errors: { base: ["This opportunity is canceled."] } }, status: :unprocessable_entity
    else
      @auction.win!(params[:bid_id])
      render json: {}
    end
  end

  def cancel
    @auction = Opportunity.find(params[:id])
    if @auction.editable?
      @auction.cancel!
      render json: {}
    else
      render json: { errors: { base: ["This opportunity cannot be canceled"] } }, status: :unprocessable_entity
    end
  end
end
