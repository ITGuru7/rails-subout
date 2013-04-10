class BidObserver < Mongoid::Observer
  observe :bid
  
  def after_create(bid)
    Event.create do |e|
      e.action = {type: :bid_created, details: {:amount => bid.amount, :bid_id => bid.id}}
      e.eventable = bid.opportunity
      e.actor_id = bid.bidder_id
    end

    bid.opportunity.update_value!

    Notifier.delay_for(5.minutes).new_bid(bid.id)
  end
end
