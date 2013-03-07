class Admin::GatewaySubscriptionsController < Admin::BaseController
  def index
    @subscriptions = GatewaySubscription.by_category(params[:category]).recent

    respond_to do |format|
      format.html
      format.csv { send_data @subscriptions.to_csv }
    end
  end

  def resend_invitation
    subscription = GatewaySubscription.pending.find(params[:id])
    Notifier.delay.subscription_confirmation(subscription.id)

    redirect_to admin_gateway_subscriptions_path, notice: "Resent invitation successfully"
  end

  def edit
    @subscription = GatewaySubscription.find(params[:id])
  end

  def update
    @subscription = GatewaySubscription.find(params[:id])
    @subscription.update_attributes(params[:gateway_subscription])
    @subscription.update_product_and_regions!(params[:gateway_subscription])
    if company = @subscription.created_company
      company.set_subscription_info
      company.save
    end
    redirect_to edit_admin_gateway_subscription_path(@subscription), notice: "Subscription updated"
  end
end
