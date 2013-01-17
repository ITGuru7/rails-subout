class Admin::GatewaySubscriptionsController < Admin::BaseController
  def index
    @subscriptions = GatewaySubscription.recent
  end
end
