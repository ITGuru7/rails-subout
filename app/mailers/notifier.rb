class Notifier < ActionMailer::Base
  def send_known_favorite_invitation(invitation)
    @buyer = invitation.buyer
    @invitation = invitation
    mail(subject: "[SubOut] Favorite Invitation from #{@buyer.name}", to: invitation.supplier_email)
  end

  def send_unknown_favorite_invitation(invitation)
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
end
