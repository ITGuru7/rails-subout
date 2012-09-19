Given /^a seller exists called "(.*?)"$/ do |name|
  @seller = FactoryGirl.create(:company, :name => name, :email => 'thomas@bostonbus.com')
end

Given /^I am logged in as a buyer called "(.*?)"$/ do |name|
  @buyer = FactoryGirl.create(:company, :name => name)
  buyer_user = FactoryGirl.create(:user, :company => @buyer)
  sign_in(buyer_user)
end

When /^I add that seller as one of my favorite suppliers$/ do
  click_on "Favorite suppliers"
  fill_in "Email", :with => @seller.email
  click_on "Find Supplier"
  page.should have_content @seller.name
  click_on "Add to my favorite suppliers"
end

Then /^that seller should be in my list of favorite suppliers$/ do
  click_on "Favorite supplier"
  page.should have_content @seller.name
end
