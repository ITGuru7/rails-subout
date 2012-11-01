require 'spec_helper'

describe Api::V1::AuctionsController do
  let(:user) { FactoryGirl.create(:user) }

  describe "GET 'index'" do
    it "responds all auctions of a company" do
      FactoryGirl.create_list(:auction, 2, buyer: user.company)
      FactoryGirl.create(:auction) 

      get :index, api_token: user.authentication_token, format: 'json'

      auctions = parse_json(response.body)
      auctions.should have(2).items
    end
  end

  describe "POST 'create'" do
    context "with valid parameters" do
      it "responds 201" do
        auction_attribtes = FactoryGirl.attributes_for(:auction)

        post :create, opportunity: auction_attribtes, api_token: user.authentication_token, format: 'json'

        response.code.should eq("201")
      end
    end

    context "with invalid parameters" do
      it "responds 422" do
        auction_attribtes = FactoryGirl.attributes_for(:auction, name: nil)

        post :create, opportunity: auction_attribtes, api_token: user.authentication_token, format: 'json'

        response.code.should eq("422")
      end
    end
  end

  describe "GET 'show'" do
    it "responds an auction" do
      auction = FactoryGirl.create(:auction, buyer: user.company)

      get :show, id: auction.id, api_token: user.authentication_token, format: 'json'

      result = parse_json(response.body)
      result["name"].should == auction.name
    end
  end

  describe "PUT 'select_winner'" do
    it "responds success" do
      auction = FactoryGirl.create(:auction, buyer: user.company)

      Opportunity.any_instance.should_receive(:win!).with('bid_id')

      put :select_winner, id: auction.id, bid_id: 'bid_id', api_token: user.authentication_token, format: 'json'

      response.should be_success
    end
  end
end
