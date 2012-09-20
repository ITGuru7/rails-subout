class Notifier < ActionMailer::Base

  def send_favorite_invitation(invitation)
    @buyer = invitation.buyer
    @invitation = invitation
    mail(subject: "[SubOut] Favorite Invitation from #{@buyer.name}", to: invitation.supplier_email)
  end
end
