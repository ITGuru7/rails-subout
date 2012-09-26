class FavoritesController < ApplicationController
  def index
    @favorites = current_company.favorite_suppliers
    @found_supplier = Company.where(:email => params[:supplier_email]).first if params[:supplier_email].present?
  end

  def destroy
    @supplier = current_company.favorite_suppliers.find(params[:id])
    current_company.remove_favorite_supplier!(@supplier)
    redirect_to favorites_path, :notice => 'Favorite supplier removed'
  end

end
