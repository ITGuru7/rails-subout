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

  describe "POST 'create'" do
    let(:favorite_invitation) { FactoryGirl.create(:favorite_invitation) }
    let(:company_attributes) { FactoryGirl.attributes_for(:company) }

    before do
      company_attributes[:created_from_invitation_id] = favorite_invitation.id
    end

    it "creates a new company" do
      expect {
        post :create, company: company_attributes, format: 'json'
      }.to change(Company, :count)

      response.should be_success
    end

    it "creates the first user of the company" do
      company_attributes["users_attributes"] = {
        "0" => {
          "password" => "password",
          "password_confirmation" => "password",
          "email" => company_attributes[:email]
        }
      }

      expect {
        post :create, company: company_attributes, format: 'json'
      }.to change(User, :count)

      user = User.last
      company = Company.last

      user.company.should == company
    end

    it "becomes a favorite company in the inviter's favorites list" do
      post :create, company: company_attributes, format: 'json'

      created_company = Company.last
      favorite_invitation.reload.buyer.favorite_supplier_ids.should include(created_company.id)
    end

    it "updates the invitation status to be accepted" do
      post :create, company: company_attributes, format: 'json'

      favorite_invitation.reload.should be_accepted
    end

    context "without invitation" do
      it "reponds with the error" do
        pending
        company_attributes.delete(:created_from_invitation_id)

        post :create, company: company_attributes, format: 'json'

        response.status.should == 422
      end
    end
  end
end
