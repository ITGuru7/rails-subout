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

  def subscription_confirmation
    subscription = GatewaySubscription.last
    Notifier.subscription_confirmation(subscription.id)
  end

  def new_opportunity
    opportunity = Opportunity.last
    company = Company.last
    Notifier.new_opportunity(opportunity.id, company.id)
  end

  def updated_product
    company = Company.last
    Notifier.updated_product(company.id)
  end
end
