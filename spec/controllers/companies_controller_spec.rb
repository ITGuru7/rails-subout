require 'spec_helper'

describe CompaniesController do
  describe 'GET dashboard' do
    before do
      sign_in_user
    end

    it 'should assign list of recent events' do
      events = [Event.new]
      Event.stub!(:recent).and_return(events)
      get 'dashboard'
      assigns(:events).should == events   
    end
  end

  describe 'GET new_supplier' do
    it "requires a pending invitation" do
      pending
      get 'new_supplier', :id => 'bogus_token'

      response.should be_redirect
    end


    it "renders new supplier form" do
      favorite_invitation = FactoryGirl.create(:favorite_invitation, :supplier => nil)

      get 'new_supplier', :id => favorite_invitation.token

      response.should render_template('new_supplier')
    end
  end

  describe 'POST create' do
    it 'creates a company' do
      favorite_invitation = FactoryGirl.create(:favorite_invitation, :supplier => nil)

      new_supplier_params = FactoryGirl.attributes_for(:company)
      new_supplier_params.merge!(
        password: 'password1',
        password_confirmation: 'password1',
        email: favorite_invitation.supplier_email,
        created_from_invitation_id: favorite_invitation.id
      )

      expect{
        post :create, :company => new_supplier_params
      }.to change(Company, :count)
    end

    it 'accepts the favorite invitation from the buyer' do
      favorite_invitation = FactoryGirl.create(:favorite_invitation, :supplier => nil)

      new_supplier_params = FactoryGirl.attributes_for(:company)
      new_supplier_params.merge!(
        password: 'password1',
        password_confirmation: 'password1',
        email: favorite_invitation.supplier_email,
        created_from_invitation_id: favorite_invitation.id
      )

      post :create, :company => new_supplier_params

      new_supplier = assigns( :new_supplier )
      favorite_invitation.buyer.reload.favorite_suppliers.should include(new_supplier)
    end

    it 'creates a user for the new company and signs them in' do
      favorite_invitation = FactoryGirl.create(:favorite_invitation, :supplier => nil)

      new_supplier_params = FactoryGirl.attributes_for(:company)
      new_supplier_params.merge!(
        password: 'password1',
        password_confirmation: 'password1',
        email: favorite_invitation.supplier_email,
        created_from_invitation_id: favorite_invitation.id
      )

      post :create, :company => new_supplier_params

      current_user = controller.current_user
      current_user.should be_present
      current_user.company.should == assigns(:new_supplier)
    end

    it 'rerenders the form on error' do
      post :create, :company => {} 

      response.should render_template('new_supplier')
    end

    it 'redirects to company dashboard on success' do
      favorite_invitation = FactoryGirl.create(:favorite_invitation, :supplier => nil)

      new_supplier_params = FactoryGirl.attributes_for(:company)
      new_supplier_params.merge!(
        password: 'password1',
        password_confirmation: 'password1',
        email: favorite_invitation.supplier_email,
        created_from_invitation_id: favorite_invitation.id
      )

      post :create, :company => new_supplier_params

      response.should redirect_to(dashboard_path)
    end 
  end
end
