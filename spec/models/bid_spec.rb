require 'spec_helper'

describe Bid do
  describe "validate_multiple_bids_on_the_same_opportunity" do
    let(:bidder) { FactoryGirl.create(:company) }

    context "reverse auction" do
      let(:opportunity) { FactoryGirl.create(:opportunity) }

      it "is invalid higher price than my previous bids" do
        my_previous_bid = FactoryGirl.create(:bid, bidder: bidder, opportunity: opportunity, amount: 100.0)

        my_new_bid = FactoryGirl.build(:bid, bidder: bidder, opportunity: opportunity, amount: 101.0)
        other_company_bid = FactoryGirl.build(:bid, opportunity: opportunity, amount: 101.0)

        my_new_bid.should_not be_valid
        other_company_bid.should be_valid
      end
    end

    context "forward auction" do
      let(:opportunity) { FactoryGirl.create(:forward_auction) }

      it "is invalid lower price than my previous bids" do
        my_previous_bid = FactoryGirl.create(:bid, bidder: bidder, opportunity: opportunity, amount: 100.0)

        my_new_bid = FactoryGirl.build(:bid, bidder: bidder, opportunity: opportunity, amount: 99.0)
        other_company_bid = FactoryGirl.build(:bid, opportunity: opportunity, amount: 99.0)

        my_new_bid.should_not be_valid
        other_company_bid.should be_valid
      end
    end
  end
end
