class Api::V1::AuctionsController < Api::V1::BaseController
  def index
    params[:page] ||= 1
    sort_by = params[:sort_by] || "created_at"
    sort_direction = params[:sort_direction] || "desc"
    opportunities = current_company.auctions.active.order_by(sort_by => sort_direction)
    meta = {
      :opportunities_count =>  opportunities.count,
      :opportunities_per_page => Opportunity.default_per_page,
      :opportunities_page => params[:page].to_i,
    }
    render json: opportunities.page(params[:page]), root: "opportunities", meta: meta
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
