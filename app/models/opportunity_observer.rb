class OpportunityObserver < Mongoid::Observer
  observe :opportunity
  
  def after_save(opportunity)
    Rails.logger.info "Observing opportunity: #{opportunity.inspect} "
 
    e = Event.new
    e.description = opportunity.description
    e.model_id = opportunity.id
    e.model_type = :opportunity
    e.company_id = opportunity.company_id
    e.save

    Company.all.each do |company| 
      if company.interested_in_event?(e) 
        Rails.logger.info "Telling company to send event : #{e.inspect}"
        company.send_event(e) 
      end
    end

  end

end
