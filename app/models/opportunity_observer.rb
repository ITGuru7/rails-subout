class OpportunityObserver < Mongoid::Observer
  observe :opportunity
  
  def after_save(opportunity)
    Rails.logger.info "Observing opportunity: #{opportunity.inspect} "
    Rails.logger.info "And the id is #{opportunity.id}"
 
    e = Event.new
    e.description = opportunity.description
    e.model_id = opportunity.id
    e.model_type = :opportunity
    e.company_id = opportunity.company_id
    e.save

    Company.all.each do |company| 
      if company.interested_in_event?(e) 
        Rails.logger.info "Telling company to send event : #{e.inspect}"
        company.send_event(e, opportunity) 
      end
    end

  end

  def after_create(opportunity)
    Rails.logger.info "Just created a new opportunity"
  end
  
end
