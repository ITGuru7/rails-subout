class BidsController < ApplicationController
  def new
    @bid = opportunity.bids.new
  end

  def create
    @bid = opportunity.bids.build(params[:bid])
    @bid.bidder = current_company
    @bid.save!

    if opportunity.quick_winnable && @bid.amount <= opportunity.win_it_now_price
      opportunity.win!(@bid)
    end

    Notifier.delay.new_bid(@bid.id)
    redirect_to opportunity
  end


  private

  helper_method :opportunity
  def opportunity
    @opportunity ||= Opportunity.find(params[:opportunity_id])
  end
end
