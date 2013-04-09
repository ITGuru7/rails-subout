class Api::V1::BidsController < Api::V1::BaseController
  def index
    params[:page] ||= 1
    bids = current_company.bids.recent
    meta = {
      :count =>  bids.count,
      :per_page => Bid.default_per_page,
      :page => params[:page].to_i,
    }
    render json: bids.includes(:opportunity).page(params[:page]), root: "bids", meta: meta
  end

  def create
    bid = opportunity.bids.build(params[:bid])
    bid.bidder = current_company
    bid.save

    respond_with_namespace(bid.opportunity, bid)
  end

  private

  helper_method :opportunity
  def opportunity
    @opportunity ||= Opportunity.find(params[:opportunity_id])
  end
end
