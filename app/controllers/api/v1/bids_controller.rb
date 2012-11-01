class Api::V1::BidsController < Api::V1::BaseController
  def index
    if params[:opportunity_id].present?
      respond_with opportunity.bids
    else
      respond_with(current_company.bids, :methods => :opportunity_title)
    end
  end

  def create
    bid = opportunity.bids.build(params[:bid])
    bid.bidder = current_company
    bid.save!

    if opportunity.quick_winnable && opportunity.win_it_now_price >= bid.amount
      opportunity.win!(bid)
    end

    Notifier.delay.new_bid(bid.id)

    respond_with(bid.opportunity, bid)
  end


  private

  helper_method :opportunity
  def opportunity
    @opportunity ||= Opportunity.find(params[:opportunity_id])
  end
end
