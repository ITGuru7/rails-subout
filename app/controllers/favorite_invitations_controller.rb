class FavoriteInvitationsController < ApplicationController
  def create
    supplier = Company.find(params[:supplier_id])
    favorite_invitation = FavoriteInvitation.create(buyer: current_company, 
                                                    supplier: supplier, 
                                                    supplier_email: supplier.email,
                                                    supplier_name: supplier.name)
    FavoriteInvitationWorker.perform_async(favorite_invitation.id)
    redirect_to favorites_path, :notice => 'Invitation sent.'
  end

  def accept
    invitation = FavoriteInvitation.find_by(:token => params[:id])
    invitation.accept!
    redirect_to :root, :notice => 'Invitation accepted.'
  end

  def send_unknown_invitation 
    #favorite_invitation = FavoriteInvitation.create(buyer: current_company, 
                                                    #email: params[:supplier_email],
                                                    #supplier_name: params[:supplier_name])
  end

end
