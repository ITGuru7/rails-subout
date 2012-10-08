Given /^a buyer exists "(.*?)"$/ do |name|
  @buyer = FactoryGirl.create(:company, name: name)
end

Given /^I am logged in as a member supplier "(.*?)"$/ do |name|
  @supplier = FactoryGirl.create(:member_supplier, name: name)
  user = FactoryGirl.create(:user, company: @supplier)
  sign_in(user)
end

Given /^(?:I|that buyer) (?:have|has) an auction "(.*?)"$/ do |name|
  @auction = @opportunity = FactoryGirl.create(:auction, buyer: @buyer, name: name)
end

When /^I bid on that opportunity$/ do
  click_on "Available Opportunities"
  click_on @opportunity.name
  click_on "Bid Now"
  fill_in :amount, with: 100.00
  click_on "Submit Bid"
  @bid = Bid.last
end

Then /^I should see my bid on that opportunity$/ do
  page.should have_content("Your bid: $#{@bid.amount}")
end

Then /^the buyer should be notified about my bid$/ do
  there_shoud_be_one_email
end

When /^I view that opportunity$/ do
  click_on "Available Opportunities"
  click_on @opportunity.name
end

Then /^I should see the win it now amount$/ do
  page.should have_content(@opportunity.win_it_now_price)
end

When /^I do a quick win on that opportunity$/ do
  click_on "Win it now"
end
