class Admin::GatewaySubscriptionsController < Admin::BaseController
  def index
    @subscriptions = GatewaySubscription.recent
  end

  def resend_invitation
    subscription = GatewaySubscription.pending.find(params[:id])
    Notifier.delay.subscription_confirmation(subscription.id)

    redirect_to admin_gateway_subscriptions_path, notice: "Resent invitation successfully"
  end
end
