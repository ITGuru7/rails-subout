class Api::V1::ProductsController < Api::V1::BaseController
  def show
    product = Chargify::Product.find_by_handle(params[:id])
    render json: product
  end
end
