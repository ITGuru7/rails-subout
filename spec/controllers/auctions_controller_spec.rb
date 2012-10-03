require 'spec_helper'


describe AuctionsController do
  before do
    sign_in_user
    @buyer = @current_company
  end

  describe 'GET index' do
    it 'lists all my auctions' do
      my_auction = FactoryGirl.create(:auction, buyer: @buyer)
      other_auction = FactoryGirl.create(:auction)

      get :index
      
      assigns(:auctions).should include(my_auction)
      assigns(:auctions).should_not include(other_auction)
    end
  end

  describe 'POST create' do
    it 'should create an auction' do
      expect {
        post :create, :opportunity => FactoryGirl.attributes_for(:auction)
      }.to change(Opportunity, :count)
    end

    it 'should redirect to dashboard' do
      post :create, :opportunity => FactoryGirl.attributes_for(:auction)
      response.should redirect_to(dashboard_path)
    end

    it 'should render the form again on failure' do
      post :create, :opportunity => FactoryGirl.attributes_for(:auction, :name => nil)
      response.should render_template("new")
    end
  end

  describe 'GET show' do
    it 'assigns auction' do
      auction = FactoryGirl.create(:auction)

      get :show, :id => auction.id

      assigns(:auction).should == auction
    end
  end

  describe 'PUT select_winner' do
    it 'records the winning bid' do
      auction = FactoryGirl.create(:auction)
      bid_id = '1'

      Opportunity.stub(:find).and_return(auction)
      auction.should_receive(:win!).with(bid_id)

      put :select_winner, :id => auction.id, bid_id: bid_id
    end
  end
end
