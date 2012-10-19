class BidObserver < Mongoid::Observer
  observe :bid
  
  def after_save(bid)
    Rails.logger.info "Observing bid: #{bid.inspect} "
 
    e = Event.new
    # Build the description
    bidder = bid.bidder
    opportunity = bid.opportunity
    e.description = "#{bidder.name} bid $#{bid.amount} on #{opportunity.name}"
    e.eventable = bid    
    e.company_id = bid.bidder_id
    e.save

    # Company.all.each do |company| 
      # if company.interested_in_event?(e) 
        # Rails.logger.info "Telling company to send event : #{e.inspect}"
        # company.send_event(e, bid) 
      # end
    # end
  end

end
