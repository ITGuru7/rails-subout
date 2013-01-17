require 'spec_helper'

describe Admin::GatewaySubscriptionsController do
  it { { get: '/admin/gateway_subscriptions' }.should route_to(controller: "admin/gateway_subscriptions", action: "index") }
end
