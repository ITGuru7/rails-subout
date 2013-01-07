require 'spec_helper'

describe Opportunity do
  describe "validation" do
    it { should allow_value(1).for(:win_it_now_price) }
    it { should_not allow_value(0).for(:win_it_now_price) }
    it { should_not allow_value(-1).for(:win_it_now_price) }
  end

  describe "#win!" do
    include EmailSpec::Helpers

    let!(:auction) { FactoryGirl.create(:auction) }
    let!(:bid) { FactoryGirl.create(:bid, opportunity: auction) }
    let!(:other_bid) { FactoryGirl.create(:bid, opportunity: auction) }

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

      find_email(bid.bidder.email, with_subject: /You won the bidding/).should_not be_nil
    end

    it "notifies to the buyer" do
      auction.win!(bid.id)

      find_email(auction.buyer.email, with_subject: /has won the bidding/).should_not be_nil
    end

    it "notities to other bidders" do
      auction.win!(bid.id)

      find_email(other_bid.bidder.email, with_subject: /You didn't win the bidding/).should_not be_nil
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
      opportunity = Opportunity.new(created_at: 2.hours.ago, bidding_duration_hrs: "1") 
      opportunity.send(:set_bidding_ends_at)
      opportunity.should_not be_bidable
    end
  end

  describe ".send_expired_notification" do
    it "sends expired opportunity notification" do
      opportunity = FactoryGirl.create(:auction, created_at: 2.hour.ago, bidding_duration_hrs: "1")
      Opportunity.send_expired_notification

      opportunity.reload.expired_notification_sent.should == true
    end
  end

  describe "#editable?" do
    let(:opportunity) { FactoryGirl.create(:opportunity) }

    subject { opportunity }
    it { should be_editable }

    context "when there is a bid" do
      before { FactoryGirl.create(:bid, opportunity: opportunity) }
      it { should_not be_editable }
    end

    context "when the opportunity is canceled" do
      before { opportunity.cancel! }
      it { should_not be_editable }
    end
  end

  describe "validate_time" do
    it "validates start_time" do
      FactoryGirl.build(:opportunity, start_time: "25:00").should_not be_valid
    end

    it "validates end_time" do
      FactoryGirl.build(:opportunity, end_time: "25:00").should_not be_valid
    end
  end
end
