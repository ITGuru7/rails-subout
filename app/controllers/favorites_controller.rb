class FavoritesController < ApplicationController
  def index
    @favorites = current_company.favorite_suppliers
    @found_supplier = Company.find_by(:email => params[:company_email]) if params[:company_email].present?
  end

  def create
    @supplier = Company.find(params[:supplier_id])
    current_company.add_favorite_supplier!(@supplier)
    redirect_to favorites_path, :notice => 'Favorite supplier added'
  end

  def destroy
    @supplier = current_company.favorite_suppliers.find(params[:id])
    current_company.remove_favorite_supplier!(@supplier)
    redirect_to favorites_path, :notice => 'Favorite supplier removed'
  end

end
