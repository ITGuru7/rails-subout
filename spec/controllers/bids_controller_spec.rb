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
  end
end
