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
end
