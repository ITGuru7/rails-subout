class OpportunityObserver < Mongoid::Observer
  observe :opportunity

  def after_create(opportunity)
    Event.create(description: opportunity.description, verb: 'created', company_id: opportunity.buyer_id, eventable: opportunity)
  end

  def after_update(opportunity)
    Event.create(description: opportunity.description, verb: 'updated', company_id: opportunity.buyer_id, eventable: opportunity)
  end
end
