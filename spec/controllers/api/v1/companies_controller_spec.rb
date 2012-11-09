require 'spec_helper'

describe Api::V1::CompaniesController do
  let(:user) { FactoryGirl.create(:user) }
  let(:company) { FactoryGirl.create(:company) }

  describe "GET 'search'" do
    it "searches company by email address" do
      get :search, email: company.email, api_token: user.authentication_token, format: :json

      json = parse_json(response.body)
      response.should be_success
      json["name"].should == company.name
    end
  end
end
