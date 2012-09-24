require 'spec_helper'

describe FavoriteInvitationsController do
  before do
    sign_in_user
  end

  describe "POST 'create'" do
    it "sends a favorite invitation email to the supplier" do
      supplier = FactoryGirl.create(:company)
      
      post :create, :supplier_id => supplier.id

      last_email.subject.should == "[SubOut] Favorite Invitation from #{@current_company.name}"
    end

  end

  describe "GET 'accept'" do
    it "adds the supplier to the buyer's list of favorites" do
      invitation = FactoryGirl.create(:favorite_invitation)

      get :accept, :id => invitation.token

      invitation.buyer.reload.favorite_suppliers.should include(invitation.supplier)
    end
  end
end
