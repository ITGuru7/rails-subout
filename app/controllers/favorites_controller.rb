class FavoritesController < ApplicationController
  def index
    @favorites = current_company.favorite_suppliers
  end
end
