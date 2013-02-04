class Notifier < ActionMailer::Base
  default :from => "noreply@subout.com"
  def send_known_favorite_invitation(buyer_id, supplier_id)
    @buyer = Company.find(buyer_id)
    @supplier = Company.find(supplier_id)

    mail(subject: "[SubOut] Favorite Invitation from #{@buyer.name}", to: @supplier.email)
  end

  def send_unknown_favorite_invitation(invitation_id)
    invitation = FavoriteInvitation.find(invitation_id)
    @buyer = invitation.buyer
    @invitation = invitation
    mail(subject: "[SubOut] New Favorite Guest Supplier Invitation from #{@buyer.name}", to: invitation.supplier_email)
  end

  def new_bid(bid_id)
    bid = Bid.find(bid_id)
    @opportunity = bid.opportunity
    @buyer = @opportunity.buyer
    @bidder = bid.bidder

    mail(subject: "New bid on: #{@opportunity.name}", to: @buyer.email)
  end

  def won_auction_to_buyer(opportunity_id)
    @auction = Opportunity.find(opportunity_id)
    @bid = @auction.winning_bid
    mail(subject: "#{@bid.bidder.name} has won the bidding on #{@auction.name}", to: @auction.buyer.email)
  end

  def won_auction_to_supplier(opportunity_id)
    @auction = Opportunity.find(opportunity_id)
    @bid = @auction.winning_bid
    mail(subject: "You won the bidding on #{@auction.name}", to: @bid.bidder.email)
  end

  def finished_auction_to_bidder(opportunity_id, bidder_id)
    @auction = Opportunity.find(opportunity_id)
    @bidder = Company.find(bidder_id)
    mail(subject: "You didn't win the bidding on #{@auction.name}.", to: @bidder.email)
  end

  def expired_auction_notification(auction_id)
    @auction = Opportunity.find(auction_id)

    mail(subject: "Your auction #{@auction.name} is expired", to: @auction.buyer.email)
  end

  def subscription_confirmation(subscription_id)
    @subscription = GatewaySubscription.find(subscription_id)

    mail(subject: "SUBOUT: confirm your subscription", to: @subscription.email)
  end

  def new_opportunity(opportunity_id, company_id)
    @opportunity = Opportunity.find(opportunity_id)
    return if @opportunity.canceled?

    @company = Company.find(company_id)
    mail(subject: "SUBOUT: new opportunity arrived", to: @company.email)
  end

  def updated_licensed_regions(company_id)
    @company = Company.find(company_id)
    mail(subject: "SUBOUT: updated licensed regions", to: @company.email)
  end

  def updated_product(company_id)
    @company = Company.find(company_id)
    mail(subject: "SUBOUT: updated subscription product", to: @company.email)
  end
end
