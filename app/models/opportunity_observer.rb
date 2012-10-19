class OpportunityObserver < Mongoid::Observer
  observe :opportunity
  
  def after_create(opportunity)
    Rails.logger.info "Observing opportunity: #{opportunity.inspect} "
    Rails.logger.info "And the id is #{opportunity.id}"
 
    e = Event.new
    e.description = opportunity.description
    e.eventable = opportunity
    e.company_id = opportunity.buyer_id
    e.save

    #TODO commented this out till we figure out how to deal with it without hanging up server every time opportunity changes
    #Company.all.each do |company| 
      #if company.interested_in_event?(e) 
        #Rails.logger.info "Telling company to send event : #{e.inspect}"
        #company.send_event(e, opportunity) 
      #end
    #end

  end

end
