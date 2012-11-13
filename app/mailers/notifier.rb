class Notifier < ActionMailer::Base
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

  def expired_auction_notification(auction_id)
    @auction = Opportunity.find(auction_id)

    mail(subject: "Your auction #{@auction.name} is expired", to: @auction.buyer.email)
  end
end
