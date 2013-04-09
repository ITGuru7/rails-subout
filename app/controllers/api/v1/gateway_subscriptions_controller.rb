class Api::V1::GatewaySubscriptionsController < ActionController::Base
  def connect_company
    redirect_to params[:company_id].present? ? "/#/sign_in" : "/#/sign_up?chargify_id=#{params[:chargify_id]}"
  end

  def update_account
    gs = GatewaySubscription.find_by(subscription_id: params[:chargify_id])
    gs.update_attribute(:payment_state, "success") if gs.has_valid_credit_card?
    redirect_to "/#/dashboard"
  end

  def create
    # Event types
    # signup_success: when user sign up
    # component_allocation_change: when user upgrade state by state plan

    event = params["event"]
    payload = params["payload"]
    subscription = payload["subscription"]

    if event == "signup_success"
      customer = subscription["customer"]

      gw_subscription = GatewaySubscription.create(
        :subscription_id => payload["subscription"]["id"],
        :customer_id => customer["id"],
        :email => customer["email"],
        :first_name => customer["first_name"],
        :last_name  => customer["last_name"],
        :organization  => customer["organization"],
        :product_handle => payload["subscription"]["product"]["handle"],
        :state => payload["subscription"]["state"]
      )

      if customer["reference"].present?
        company = Company.find(customer["reference"])
        unless company.created_from_subscription_id.present?
          company.created_from_subscription = gw_subscription
          company.set_subscription_info
          company.save
          Notifier.delay.updated_product(company.id)
        end
      else
        Notifier.delay.subscription_confirmation(gw_subscription.id)
      end
    elsif event == "subscription_state_change"
      gw_subscription = GatewaySubscription.find_by(subscription_id: subscription["id"])
      gw_subscription.update_attribute(:state, subscription["state"])
    elsif event == "payment_failure"
      gw_subscription = GatewaySubscription.find_by(subscription_id: subscription["id"])
      gw_subscription.update_attribute(:payment_state, "failure")
    elsif event == "payment_success"
      gw_subscription = GatewaySubscription.find_by(subscription_id: subscription["id"])
      gw_subscription.update_attribute(:payment_state, "success")
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
