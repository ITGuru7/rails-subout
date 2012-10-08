require 'spec_helper'

describe BidsController do
  let(:opportunity) { FactoryGirl.create(:opportunity) }

  before do
    sign_in_user
  end

  describe "POST 'create'" do
    def do_request
      post :create, :opportunity_id => opportunity.id , :bid => {:amount => 100}
    end

    it 'creates the bid' do
      expect{
        do_request
      }.to change(opportunity.bids, :count)
    end

    it 'redirects to the opportunity show page on success' do
      do_request

      response.should redirect_to opportunity
    end

    it 'sends notification to the buyer' do
      do_request

      last_email.should deliver_to(opportunity.buyer.email)
    end

    it "wins the bidding if the bid amount <= the opportunity's win it now price" do
      quick_winnable_opportunity = FactoryGirl.create(:quick_winnable_auction, win_it_now_price: 10.0)

      post :create, :opportunity_id => quick_winnable_opportunity.id , :bid => {:amount => 10.0}

      quick_winnable_opportunity.reload.should be_won
    end
  end
end
