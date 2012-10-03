Given /^I am signed in as a buyer/ do 
  @buyer = FactoryGirl.create(:company)
  buyer_user = FactoryGirl.create(:user, :company => @buyer)
  sign_in(buyer_user)
end
