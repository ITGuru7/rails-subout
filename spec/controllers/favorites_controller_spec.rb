require 'spec_helper'

describe FavoritesController do
  before do
    sign_in_user
  end

  describe "GET 'index'" do
    it 'assigns favorites' do
      favorite_company = FactoryGirl.create(:company)
      @current_company.add_favorite_supplier!(favorite_company)

      get :index

      assigns(:favorites).to_a.should == [favorite_company]
    end

    it 'searches for a supplier' do
      supplier = FactoryGirl.create(:company, :email => 'some_known@email.com')

      get :index, :supplier_email => supplier.email

      assigns(:found_supplier).should == supplier
    end
  end

  describe "DELETE 'destroy'" do
    it "removes a supplier from the current_company's list of favorites" do
      supplier = FactoryGirl.create(:company)
      @current_company.add_favorite_supplier!(supplier)

      delete :destroy, :id => supplier.id

      @current_company.reload.favorite_supplier_ids.should_not include(supplier.id)
    end
  end
end
