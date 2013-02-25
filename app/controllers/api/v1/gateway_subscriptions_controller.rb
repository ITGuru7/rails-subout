class Api::V1::GatewaySubscriptionsController < ActionController::Base
  def connect_company
    redirect_to params[:company_id].present? ? "/#/sign_in" : "/#/sign_up?chargify_id=#{params[:chargify_id]}"
  end

  def create
    # Event types
    # signup_success: when user sign up
    # component_allocation_change: when user upgrade state by state plan

    event = params["event"]
    payload = params["payload"]

    if event == "signup_success"
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

      if customer["reference"].present?
        company = Company.find(customer["reference"])
        unless company.created_from_subscription_id.present?
          company.created_from_subscription = gw_subscription
          company.set_subscription_info
          company.save
        end
      else
        Notifier.delay.subscription_confirmation(gw_subscription.id)
      end
    end
    render json: {}
  end

  def show
    if params[:chargify_id]
      subscription = GatewaySubscription.pending.find_by(subscription_id: params[:chargify_id])
    else
      subscription = GatewaySubscription.pending.find(params[:id])
    end

    render json: subscription
  end

  #NOTE: it's used for testing with posting fake chargify callback
  def test_form
    render 'gateway_subscriptions/test_form'
  end
end
