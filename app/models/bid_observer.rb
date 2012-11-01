class BidObserver < Mongoid::Observer
  observe :bid
  
  def after_save(bid)
    Event.create do |e|
      bidder = bid.bidder
      opportunity = bid.opportunity

      e.description = "#{bidder.name} bid $#{bid.amount} on #{opportunity.name}"
      e.eventable = bid 
      e.company_id = bid.bidder_id
    end
  end

  def after_create(bid)
    Notifier.delay.new_bid(bid.id)
  end
end
