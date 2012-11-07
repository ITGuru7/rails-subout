class Api::V1::FavoriteInvitationsController < Api::V1::BaseController
  def create_for_unknown_supplier
    @favorite_invitation = FavoriteInvitation.new(params[:favorite_invitation])
    @favorite_invitation.buyer = current_company
    if @favorite_invitation.save
      Notifier.delay.send_unknown_favorite_invitation(@favorite_invitation.id)
      redirect_to dashboard_path
    end
  end

  def accept
    invitation = FavoriteInvitation.pending.find_by(:token => params[:id])
    invitation.accept!
    redirect_to root_path, :notice => 'Invitation accepted.'
  end
end
