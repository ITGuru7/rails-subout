class Api::V1::FavoriteInvitationsController < Api::V1::BaseController
  def create
    @favorite_invitation = FavoriteInvitation.new(params[:favorite_invitation])
    @favorite_invitation.buyer = current_company
    if @favorite_invitation.save
      Notifier.delay.send_unknown_favorite_invitation(@favorite_invitation.id)
    end

    respond_with @favorite_invitation
  end

  def accept
    invitation = FavoriteInvitation.pending.find_by(:token => params[:id])
    invitation.accept!

    respond_with invitation
  end
end
