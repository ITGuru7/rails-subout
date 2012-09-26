require 'spec_helper'

describe FavoriteInvitationsController do
  before do
    sign_in_user
  end

  describe "POST 'create_for_known_supplier'" do
    it "sends a favorite invitation email to the supplier" do
      supplier = FactoryGirl.create(:company)
      
      post :create_for_known_supplier, :supplier_id => supplier.id

      last_email.subject.should == "[SubOut] Favorite Invitation from #{@current_company.name}"
    end
  end

  describe "POST 'create_for_unknown_supplier'" do
    context "success" do
      it "redirects to dasboard" do
        invitation_params = {:supplier_name => 'Boston Bus', :supplier_email => 'tom@bostonbus.com'}

        post :create_for_unknown_supplier, :favorite_invitation => invitation_params

        response.should redirect_to(dashboard_path)
      end

      it "sends a new favorite guest supplier invitation email" do
        invitation_params = {:supplier_name => 'Boston Bus', :supplier_email => 'tom@bostonbus.com'}
        
        post :create_for_unknown_supplier, :favorite_invitation => invitation_params

        last_email.subject.should == "[SubOut] New Favorite Guest Supplier Invitation from #{@current_company.name}"
      end
    end

  end

  describe "GET 'accept'" do
    it "adds the supplier to the buyer's list of favorites" do
      invitation = FactoryGirl.create(:favorite_invitation)

      get :accept, :id => invitation.token

      invitation.buyer.reload.favorite_suppliers.should include(invitation.supplier)
    end

    it "only searches pending invitations" do
      fail
    end
  end
end
