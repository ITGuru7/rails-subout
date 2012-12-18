class OpportunityObserver < Mongoid::Observer
  observe :opportunity

  def after_create(opportunity)
    create_event(opportunity, :opportunity_created)
    send_notification_to_companies(opportunity)
  end

  def after_update(opportunity)
    if opportunity.canceled_changed?
      create_event(opportunity, :opportunity_canceled)
    elsif opportunity.winning_bid_id_changed?
      Event.create(actor_id: opportunity.winning_bid.bidder_id, action: {type: :opportunity_bidding_won}, eventable: opportunity)
    else
      create_event(opportunity, :opportunity_updated)
    end
  end

  private

  def create_event(opportunity, type)
    Event.create!(actor_id: opportunity.buyer_id, action: {type: type}, eventable: opportunity)
  end

  def send_notification_to_companies(opportunity)
    companies = Company.notified_recipients_by(opportunity)

    companies.each do |company|
      Notifier.delay_for(5.minutes).new_opportunity(opportunity.id, company.id)
    end
  end
end
