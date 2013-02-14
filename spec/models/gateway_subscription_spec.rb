require 'spec_helper'

describe GatewaySubscription, "update_regions!" do
  let(:subscription) { FactoryGirl.create(:state_by_state_subscription) }
  let(:company) { FactoryGirl.create(:company, created_from_subscription: subscription) }
  let(:components) { subscription.regions.map { |r| stub(name: r).as_null_object } }
  let(:chargify_sub) { stub(components: components) }

  it "updates regions of subscription and company" do
    subscription.regions.should == ["California", "New York"]
    company.reload.regions.should == ["California", "New York"]
    Chargify::Subscription.stub(:find).and_return(chargify_sub)
    company.update_regions!(["California", "Ohio"])

    subscription.reload.regions.should == ["California", "Ohio"]
    company.reload.regions.should == ["California", "Ohio"]
  end

  context "when nil is given" do
    it "should not raise error" do
      Chargify::Subscription.stub(:find).and_return(chargify_sub)
      expect {
        company.update_regions!(nil).should == false
      }.not_to raise_error

      company.errors[:base].should == ["Regions cannot be nil"]
    end
  end
end
