class FavoriteInvitationWorker
  include Sidekiq::Worker
  
  def perform(id)
    invitation = FavoriteInvitation.find(id)

    if invitation.supplier
      Notifier.send_known_favorite_invitation(invitation).deliver
    else
      Notifier.send_unknown_favorite_invitation(invitation).deliver
    end
  end
end
