Given /^a supplier exists called "(.*?)"$/ do |name|
  @supplier = FactoryGirl.create(:company, :name => name, :email => 'thomas@bostonbus.com')
end

Given /^I am logged in as a buyer$/ do
  @buyer = FactoryGirl.create(:company)
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
  page.should have_content @supplier.name
  page.should_not have_content "Add to my favorite suppliers"
end


Given /^I have "(.*?)" as a favorite supplier$/ do |name|
  @supplier = FactoryGirl.create(:company, :name => name)
  @buyer.add_favorite_supplier!(@supplier)
end

When /^I remove "(.*?)" from my favorites$/ do |name|
  visit favorites_path
  within "##{dom_id(@supplier)}" do
    click_on 'delete'
  end
end

Then /^"(.*?)" should not be in my favorites$/ do |name|
  page.should_not have_content( @supplier.name )
end
