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
  end
end
