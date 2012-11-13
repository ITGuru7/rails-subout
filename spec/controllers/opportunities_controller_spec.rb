require 'spec_helper'

describe OpportunitiesController do
  before do
    pending
    @user = sign_in_user
  end

  describe "GET 'index'" do
    it 'assigns available opportunities' do
      opportunities = stub
      Opportunity.stub!(:available).and_return(opportunities)

      get :index

      assigns(:opportunities).should == opportunities
    end
  end

  describe "GET 'show'" do
    it 'assigns opportunity' do
      opportunity = FactoryGirl.create(:opportunity)

      get :show, id: opportunity.id 

      assigns(:opportunity).should == opportunity
    end
  end
end

