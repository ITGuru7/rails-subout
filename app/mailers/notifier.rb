class Notifier < ActionMailer::Base
  default :from => "noreply@suboutapp.com"

  def send_known_favorite_invitation(buyer_id, supplier_id)
    @buyer = Company.find(buyer_id)
    @supplier = Company.find(supplier_id)

    mail(subject: "[SubOut] Favorite Invitation from #{@buyer.name}", to: @supplier.notifiable_email)
  end

  def send_unknown_favorite_invitation(invitation_id)
    invitation = FavoriteInvitation.find(invitation_id)
    @buyer = invitation.buyer
    @invitation = invitation
    mail(subject: "[SubOut] New Favorite Guest Supplier Invitation from #{@buyer.name}", to: invitation.supplier_email)
  end

  def new_bid(bid_id)
    if @bid = Bid.active.where(id: bid_id).first
      @opportunity = @bid.opportunity
      @buyer = @opportunity.buyer
      @bidder = @bid.bidder

      mail(subject: "[SubOut] New bid on: #{@opportunity.name}", to: @buyer.notifiable_email) if @buyer.notifiable?
    end
  end

  def won_auction_to_buyer(opportunity_id)
    @auction = Opportunity.find(opportunity_id)
    @bid = @auction.winning_bid
    @poster = @auction.buyer
    @bidder = @bid.bidder

    mail(subject: "[SubOut] #{@bid.bidder.name} has won the bidding on #{@auction.name}", to: @poster.notifiable_email) if @poster.notifiable?
  end

  def won_auction_to_supplier(opportunity_id)
    @auction = Opportunity.find(opportunity_id)
    @bid = @auction.winning_bid
    @buyer = @auction.buyer
    @bidder = @bid.bidder
    mail(subject: "[SubOut] You won the bidding on #{@auction.name}", to: @bidder.notifiable_email) if @bidder.notifiable?
  end

  def finished_auction_to_bidder(opportunity_id, bidder_id)
    @auction = Opportunity.find(opportunity_id)
    @bidder = Company.find(bidder_id)
    mail(subject: "[SubOut] You didn't win the bidding on #{@auction.name}.", to: @bidder.notifiable_email) if @bidder.notifiable?
  end

  def expired_auction_notification(auction_id)
    @auction = Opportunity.find(auction_id)
    @poster = @auction.buyer
    mail(subject: "[SubOut] Your auction #{@auction.name} is expired", to: @poster.notifiable_email) if @poster.notifiable?
  end

  def completed_auction_notification_to_buyer(opportunity_id)
    @auction = Opportunity.find(opportunity_id)
    @bid = @auction.winning_bid
    @poster = @auction.buyer
    @bidder = @bid.bidder

    @rating = Rating.where(rater_id: @poster.id, ratee_id: @bidder.id).first
    @rating = Rating.create(rater_id: @poster.id, ratee_id: @bidder.id) if @rating.blank?
    @rating.unlock!

    mail(subject: "[SubOut] Your auction #{@auction.name} is completed", to: @poster.notifiable_email) if @poster.notifiable?
  end

  def completed_auction_notification_to_supplier(opportunity_id)
    @auction = Opportunity.find(opportunity_id)
    @bid = @auction.winning_bid
    @poster = @auction.buyer
    @bidder = @bid.bidder

    @rating = Rating.where(rater_id: @bidder.id, ratee_id: @poster.id).first
    @rating = Rating.create(rater_id: @bidder.id, ratee_id: @poster.id) if @rating.blank?
    @rating.unlock!
    mail(subject: "[SubOut] Your auction #{@auction.name} is completed", to: @bidder.notifiable_email) if @bidder.notifiable?
  end

  def subscription_confirmation(subscription_id)
    @subscription = GatewaySubscription.find(subscription_id)

    mail(subject: "[SubOut] confirm your subscription", to: @subscription.email)
  end

  def new_opportunity(opportunity_id, company_id)
    @opportunity = Opportunity.find(opportunity_id)
    return if @opportunity.canceled?

    @company = Company.find(company_id)
    mail(subject: "[SubOut] new opportunity arrived", to: @company.notifiable_email)
  end

  def updated_licensed_regions(company_id)
    @company = Company.find(company_id)
    mail(subject: "[SubOut] updated licensed regions", to: @company.notifiable_email)
  end

  def updated_product(company_id)
    @company = Company.find(company_id)
    mail(subject: "[SubOut] updated subscription product", to: @company.notifiable_email)
  end
end
