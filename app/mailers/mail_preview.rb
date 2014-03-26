class MailPreview < MailView
  def send_known_favorite_invitation
    buyer, supplier = Company.all[0, 2]
    Notifier.send_known_favorite_invitation(buyer.id, supplier.id)
  end

  def send_unknown_favorite_invitation
    invitation = FavoriteInvitation.first
    Notifier.send_unknown_favorite_invitation(invitation.id)
  end

  def new_bid
    bid = Bid.last
    Notifier.new_bid(bid.id)
  end

  def new_negotiation 
    bid = Bid.last
    Notifier.new_negotiation(bid.id)
  end

  def won_auction_to_buyer
    opportunity = Opportunity.where(:winning_bid_id.ne => nil).last
    Notifier.won_auction_to_buyer(opportunity.id)
  end

  def won_auction_to_supplier
    opportunity = Opportunity.where(:winning_bid_id.ne => nil).last
    Notifier.won_auction_to_supplier(opportunity.id)
  end

  def finished_auction_to_bidder
    opportunity = Opportunity.where(:winning_bid_id.ne => nil).last
    Notifier.finished_auction_to_bidder(opportunity.id, opportunity.bids.first.bidder_id)
  end

  def expired_auction_notification
    opportunity = Opportunity.where(:winning_bid_id.ne => nil).last
    Notifier.expired_auction_notification(opportunity.id)
  end

  def completed_auction_notification_to_buyer 
    opportunity = Opportunity.where(:winning_bid_id.ne => nil).last
    Notifier.completed_auction_notification_to_buyer(opportunity.id)
  end

  def completed_auction_notification_to_supplier 
    opportunity = Opportunity.where(:winning_bid_id.ne => nil).last
    Notifier.completed_auction_notification_to_supplier(opportunity.id)
  end

  def subscription_confirmation
    subscription = GatewaySubscription.last
    Notifier.subscription_confirmation(subscription.id)
  end

  def new_opportunity
    opportunity = Opportunity.last
    company = Company.last
    Notifier.new_opportunity(opportunity.id, company.id)
  end

  def expired_card
    company = Company.last
    Notifier.expired_card(company.id)
  end

  def locked_company
    company = Company.last
    Notifier.locked_company(company.id)
  end

  def updated_product
    company = Company.last
    Notifier.updated_product(company.id)
  end

  def new_vehicle
    vehicle = Vehicle.first
    Notifier.new_vehicle(vehicle.id)
  end

  def update_vehicle
    vehicle = Vehicle.first
    Notifier.update_vehicle(vehicle.id, vehicle)
  end

  def remove_vehicle
    vehicle = Vehicle.first
    Notifier.remove_vehicle(vehicle)
  end

  def remind_registration_to_user
    subscription = GatewaySubscription.last
    Notifier.remind_registration_to_user(subscription.id)
  end

  def remind_registration_to_admin
    subscription = GatewaySubscription.last
    Notifier.remind_registration_to_admin(subscription.id)
  end

  def daily_reminder
    company = Company.last
    Notifier.daily_reminder(company.id)
  end
end
