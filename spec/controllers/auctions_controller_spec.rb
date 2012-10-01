require 'spec_helper'


describe AuctionsController do
  before do
    sign_in_user
    @buyer = @current_company
  end

  describe 'GET index' do
    it 'lists all my auctions' do
      my_auction = FactoryGirl.create(:opportunity, buyer: @buyer)
      other_auction = FactoryGirl.create(:opportunity)

      get :index
      
      assigns(:auctions).should include(my_auction)
      assigns(:auctions).should_not include(other_auction)
    end
  end
end
