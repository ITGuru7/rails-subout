require 'spec_helper'

describe Api::V1::BidsController do
  let(:user) { FactoryGirl.create(:user) }

  describe "GET 'index'" do
    it "responds all bids of user's company" do
      FactoryGirl.create_list(:bid, 2, bidder: user.company)
      FactoryGirl.create(:bid)

      get :index, api_token: user.authentication_token, format: 'json'

      bids = parse_json(response.body)
      bids.should have(2).items
    end

    context "with opportunity_id" do
      let(:opportunity) { FactoryGirl.create(:opportunity) }

      it "responds bids belong to the opportunity" do
        FactoryGirl.create_list(:bid, 2, opportunity: opportunity)
        FactoryGirl.create(:bid)

        get :index, opportunity_id: opportunity.id, api_token: user.authentication_token, format: 'json'

        bids = parse_json(response.body)
        bids.should have(2).items
      end
    end
  end

  describe "POST 'create'" do
    it "responds bid" do
      opportunity = FactoryGirl.create(:opportunity)
      bid_attributes = FactoryGirl.attributes_for(:bid)

      expect {
        post :create, bid: bid_attributes, opportunity_id: opportunity.id, api_token: user.authentication_token, format: 'json'
      }.to change(opportunity.bids, :count).by(1)

      response.code.should eq("201")
    end
  end
end
