class BidObserver < Mongoid::Observer
  observe :bid
  
  def after_save(bid)
    Rails.logger.info "Observing bid: #{bid.inspect} "
 
    e = Event.new
    # Build the description
    company = bid.company
    opportunity = bid.opportunity
    e.description = "#{company.name} bid #{bid.amount} on #{opportunity.name}"
    e.model_id = bid.id
    e.model_type = :bid
    e.company_id = bid.posting_company_id
    e.save

    Company.all.each do |company| 
      if company.interested_in_event?(e) 
        Rails.logger.info "Telling company to send event : #{e.inspect}"
        company.send_event(e, bid) 
      end
    end

  end

end
