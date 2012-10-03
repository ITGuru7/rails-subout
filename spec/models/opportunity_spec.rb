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

  describe "#win!" do
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

      last_email.should deliver_to(bid.bidder.email)
    end
  end
end
