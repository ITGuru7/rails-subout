Given /^a supplier exists called "(.*?)"$/ do |name|
  @supplier = FactoryGirl.create(:company, :name => name, :email => 'thomas@bostonbus.com')
end

Given /^I am logged in as a buyer called "(.*?)"$/ do |name|
  @buyer = FactoryGirl.create(:company, :name => name)
  buyer_user = FactoryGirl.create(:user, :company => @buyer)
  sign_in(buyer_user)
end

When /^I add that supplier as one of my favorite suppliers$/ do
  click_on "Favorite suppliers"
  fill_in "Email", :with => @supplier.email
  click_on "Find Supplier"
  page.should have_content @supplier.name
  click_on "Add to my favorite suppliers"
end

Then /^that supplier should be in my list of favorite suppliers$/ do
  click_on "Favorite supplier"
  page.should have_content @supplier.name
end
