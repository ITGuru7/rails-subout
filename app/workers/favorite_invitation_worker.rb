class FavoriteInviationWorker
  include Sidekiq::Worker
  
  def perform(id)
    invitation = FavoriteInvitation.find(id)

    Notifier.send_favorite_invitation(invitation).deliver
  end
end
