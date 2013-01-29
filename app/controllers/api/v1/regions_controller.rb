class Api::V1::RegionsController < Api::V1::BaseController
  def index
    render json: GatewaySubscription.region_prices
  end
end
