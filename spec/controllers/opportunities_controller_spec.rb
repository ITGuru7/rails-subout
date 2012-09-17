require 'spec_helper'

describe OpportunitiesController do
  before do
    @user = sign_in_user
  end

  describe "GET 'index'" do
    it "assigns all my needs and only MY needs" do
      my_needs = FactoryGirl.create(:opportunity, :company => @user.company)
      my_need_2 = FactoryGirl.create(:opportunity, :company => @user.company)
      not_mine = FactoryGirl.create(:opportunity)

      get :index

      assigns(:opportunities).should == [my_needs, my_need_2]
      assigns(:opportunities).should_not include(not_mine)
    end

  end

  describe 'POST create' do
    it 'should create an opportunity' do
      expect {
        post :create, :opportunity => FactoryGirl.attributes_for(:opportunity)
      }.to change(Opportunity, :count)
    end

    it 'should redirect to dashboard' do
      post :create, :opportunity => FactoryGirl.attributes_for(:opportunity)
      response.should redirect_to(dashboard_path)
    end

    it 'should render the form again on failure' do
      post :create, :opportunity => FactoryGirl.attributes_for(:opportunity, :name => nil)
      response.should render_template("new")
    end
  end
end

