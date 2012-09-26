class FavoriteInvitationsController < ApplicationController
  def new
    default_custom_message = "Hi <supplier_name>, #{current_company.name} would to add you as a favorite supplier on Subout."

    @favorite_invitation = FavoriteInvitation.new(
      supplier_email: params[:supplier_email],
      :custom_message => default_custom_message
    )
  end

  def create_for_known_supplier
    supplier = Company.find(params[:supplier_id])
    favorite_invitation = FavoriteInvitation.create(buyer: current_company, 
                                                    supplier: supplier, 
                                                    supplier_email: supplier.email,
                                                    supplier_name: supplier.name)
    FavoriteInvitationWorker.perform_async(favorite_invitation.id)
    redirect_to favorites_path, :notice => 'Invitation sent.'
  end

  def create_for_unknown_supplier
    @favorite_invitation = FavoriteInvitation.new(params[:favorite_invitation])
    @favorite_invitation.buyer = current_company
    if @favorite_invitation.save
      FavoriteInvitationWorker.perform_async(@favorite_invitation.id)
      redirect_to dashboard_path
    end
  end

  def accept
    invitation = FavoriteInvitation.find_by(:token => params[:id])
    invitation.accept!
    redirect_to :root, :notice => 'Invitation accepted.'
  end


end
