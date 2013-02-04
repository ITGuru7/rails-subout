class Api::V1::GatewaySubscriptionsController < ActionController::Base
  def create
    payload = params["payload"]
    customer = payload["subscription"]["customer"]
    gw_subscription = GatewaySubscription.create(
      :subscription_id => payload["subscription"]["id"],
      :customer_id => customer["id"],
      :email => customer["email"],
      :first_name => customer["first_name"],
      :last_name  => customer["last_name"],
      :organization  => customer["organization"],
      :product_handle => payload["subscription"]["product"]["handle"]
    )

    Notifier.delay.subscription_confirmation(gw_subscription.id)

    render json: {}
  end

  def show
    subscription = GatewaySubscription.pending.find(params[:id])

    render json: subscription
  end

  #NOTE: it's used for testing with posting fake chargify callback
  def test_form
    render 'gateway_subscriptions/test_form'
  end
end
