require 'spec_helper'

describe OpportunitiesController do
  before do
   sign_in_user
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

