Given /^a seller exists called "(.*?)"$/ do |name|
  @seller = FactoryGirl.create(:company, :name => name, :email => 'thomas@bostonbus.com')
end

Given /^I am logged in as a buyer called "(.*?)"$/ do |name|
  @buyer = FactoryGirl.create(:company, :name => name)
  buyer_user = FactoryGirl.create(:user, :company => @buyer)
  sign_in(buyer_user)
end

When /^I add that seller as one of my favorites$/ do
  click_on "Favorites"
  fill_in "Email", :with => @seller.email
  click_on "Find Seller"
  page.should have_content @seller.name
  click_on "Add #{@seller.name} to my favorite sellers"
end

Then /^"(.*?)" should be in my list of favorites$/ do |name|
  pending
end
