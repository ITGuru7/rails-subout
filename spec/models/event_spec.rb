require 'spec_helper'

describe Event do
  describe ".for" do
    let!(:ca_opportunity) {FactoryGirl.create(:opportunity, regions: ["CA"])}
    let!(:wa_opportunity) {FactoryGirl.create(:opportunity, regions: ["WA"])}
    let(:national_plan_company) {FactoryGirl.create(:company)}
    let(:ca_state_plan_company) {FactoryGirl.create(:ca_company)}

    context "a company with national plan is given" do
      it "returns all events" do
        Event.for(national_plan_company).should have(2).opportunities
      end
    end

    context "a company with state by state plan is given" do
      subject { Event.for(ca_state_plan_company).map(&:eventable) }
      it { should == [ca_opportunity] }
    end
  end
end
