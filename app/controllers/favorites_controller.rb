class FavoritesController < ApplicationController
  def index
    @favorites = current_company.favorite_suppliers
    @found_supplier = Company.find_by(:email => params[:company_email]) if params[:company_email].present?
  end

  def create_invitation
    supplier = Company.find(params[:supplier_id])
    favorite_invitation = FavoriteInvitation.create(buyer: current_company, 
                                                    supplier: supplier, 
                                                    email: supplier.email,
                                                    supplier_name: supplier.name)
    FavoriteInviationWorker.perform_async(favorite_invitation.id)
    redirect_to favorites_path, :notice => 'Favorite supplier added'
  end

  def send_unknown_invitation 
    #favorite_invitation = FavoriteInvitation.create(buyer: current_company, 
                                                    #email: params[:supplier_email],
                                                    #supplier_name: params[:supplier_name])
  end

  def destroy
    @supplier = current_company.favorite_suppliers.find(params[:id])
    current_company.remove_favorite_supplier!(@supplier)
    redirect_to favorites_path, :notice => 'Favorite supplier removed'
  end

end
