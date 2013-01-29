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
end
