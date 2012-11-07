class Api::V1::FavoritesController < Api::V1::BaseController
  def index
    @favorites = current_company.favorite_suppliers

    respond_with(@favorites)
  end

  def create
    supplier = Company.find(params[:supplier_id])
    current_company.add_favorite_supplier!(supplier)

    Notifier.delay.send_known_favorite_invitation(current_company.id, supplier.id)

    respond_with(favorite_invitation)
  end

  def destroy
    @supplier = current_company.favorite_suppliers.find(params[:id])
    current_company.remove_favorite_supplier!(@supplier)
    redirect_to favorites_path, :notice => 'Favorite supplier removed'
  end
end
