require 'spec_helper'

describe Bid do
  #describe "validate_opportunity_bidable" do
    #it "is invalid when the opportunity is not biddable by this bidder" do
      #let(:bidder) { FactoryGirl.create(:company) }
      #let(:opportunity) { FactoryGirl.create(:opportunity) }
      #opportunity.stub(:biddable_by?).with(bidder).and_return(false)

      #my_new_bid = FactoryGirl.build(:bid, bidder: bidder, opportunity: opportunity, amount: 101.0)
      #my_new_bid.should_not be_valid
    #end
  #end

  describe "validation" do
    it { should allow_value(1).for(:amount) }
    it { should_not allow_value(0).for(:amount) }
    it { should_not allow_value(-1).for(:amount) }
    it { should ensure_length_of(:comment).is_at_most(255) }
  end

  describe "validate_bidable_by_bidder" do
    let(:buyer) { FactoryGirl.create(:company) }
    let(:bidder) { FactoryGirl.create(:company) }

    context "favorite only opportunity" do
      let(:opportunity) { FactoryGirl.create(:opportunity, buyer: buyer, for_favorites_only: true) }

      it "is not valid if bidder is not added to favorites" do
        FactoryGirl.build(:bid, opportunity: opportunity, bidder: bidder).should_not be_valid
      end

      it "is valid if the bidder is added to favorites" do
        buyer.add_favorite_supplier!(bidder)
        FactoryGirl.build(:bid, opportunity: opportunity, bidder: bidder).should be_valid
      end
    end
  end

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

  describe "validate_reserve_met" do
    context "reverse auction" do
      let(:opportunity) { FactoryGirl.create(:opportunity, reserve_amount: 1000) }

      it "should be invalid if amount > reserve amount" do
        bid = FactoryGirl.build(:bid, opportunity: opportunity, amount: 1001)
        bid.should_not be_valid
      end
    end

    context "forward auction" do
      let(:opportunity) { FactoryGirl.create(:forward_auction, reserve_amount: 1000) }

      it "should be invalid if amount < reserve amount" do
        bid = FactoryGirl.build(:bid, opportunity: opportunity, amount: 999)
        bid.should_not be_valid
      end
    end
  end

  describe "validate_dot_number_of_bidder" do
    let(:bidder) { FactoryGirl.create(:company, dot_number: "") }
    let(:opportunity) { FactoryGirl.create(:opportunity) }

    it "should be invalid if bidder doesn't have dot number" do
      FactoryGirl.build(:bid, opportunity: opportunity, bidder: bidder).should_not be_valid
    end
  end
end
