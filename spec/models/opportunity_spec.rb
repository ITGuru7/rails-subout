require 'spec_helper'

describe Opportunity do
  describe ".available" do
    it 'returns all opportunities sorted by the newest' do
      opportunities = FactoryGirl.create_list(:opportunity, 3)

      result = Opportunity.available

      result.first.should == opportunities.last
      result.last.should == opportunities.first
    end
  end
end
