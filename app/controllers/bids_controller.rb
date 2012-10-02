class BidsController < ApplicationController
  def new
    @bid = opportunity.bids.new
  end

  def create
    @bid = opportunity.bids.build(params[:bid])
    @bid.bidder = current_company
    @bid.save!

    Notifier.delay.new_bid(@bid.id)
    redirect_to opportunity
  end


  private

  helper_method :opportunity
  def opportunity
    @opportunity ||= Opportunity.find(params[:opportunity_id])
  end
end
