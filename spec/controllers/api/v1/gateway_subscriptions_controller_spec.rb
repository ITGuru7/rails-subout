require 'spec_helper'

describe Api::V1::GatewaySubscriptionsController, "POST create" do
  it "creates a gateway subscription" do
    payload = {
      subscription: {
        id: "subscription_id",
        customer: {
          id: "customer_id",
          email: "customer@email.com",
          first_name: "Bill",
          last_name: "James",
          organization: "Company"
        },
        product: {
          handle: "state-by-state-service"
        }
      }
    }

    post :create, payload: payload

    response.status.should == 200
    GatewaySubscription.should have(1).item
  end
end

describe Api::V1::GatewaySubscriptionsController, "GET show" do
  it "returns json for gateway subscription" do
    subscription = FactoryGirl.create(:gateway_subscription)

    get :show, id: subscription.id

    response.status.should == 200
    parse_json(response.body).should be
  end
end
