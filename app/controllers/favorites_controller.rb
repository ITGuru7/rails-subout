class FavoritesController < ApplicationController
  def index
    @favorites = current_company.favorite_suppliers
    if company_email = params[:company_email]
      @found_supplier = Company.where(:email => company_email).first
    end
  end

  def create
    @supplier = Company.find(params[:supplier_id])
    current_company.add_favorite_supplier!(@supplier)
    redirect_to favorites_path, :notice => 'Favorite supplier added'
  end

end
