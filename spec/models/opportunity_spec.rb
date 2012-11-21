require 'spec_helper'

describe Opportunity do
  describe "#win!" do
    include EmailSpec::Helpers

    let(:auction) { FactoryGirl.create(:auction) }
    let(:bid) { FactoryGirl.create(:bid, opportunity: auction) }

    it "closes the auction"  do
      expect {
        auction.win!(bid.id)
      }.to change(auction, :bidding_done)
    end

    it "records the winning bid" do
      expect {
        auction.win!(bid.id)
      }.to change(auction, :winning_bid_id)

    end

    it "notifies the winner" do
      auction.win!(bid.id)

      find_email(bid.bidder.email, :with_subject => /You won the bidding/).should_not be_nil
    end
  end

  describe "#bidable?" do
    it "returns false if the opportunity has been canceled" do
      opportunity = Opportunity.new(canceled: true)

      opportunity.should_not be_bidable
    end

    it "returns false if the opportunity has been done" do
      opportunity = Opportunity.new(bidding_done: true)

      opportunity.should_not be_bidable
    end

    it "returns false if the opportunity has been won by a company" do
      opportunity = Opportunity.new(winning_bid_id: "123")

      opportunity.should_not be_bidable
    end

    it "returns false if the opportunity has been ended" do
      opportunity = Opportunity.new(bidding_ends: 1.day.ago) 

      opportunity.should_not be_bidable
    end
  end
end
