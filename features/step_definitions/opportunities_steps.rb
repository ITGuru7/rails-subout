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
  bid
end

Then /^I should see my bid on that opportunity$/ do
  page.should have_content("Your bid: $#{@bid.amount}")
end

Then /^the buyer should be notified about my bid$/ do
  step %{"#{@buyer.email}" should receive an email}
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

When /^I bid on that opportunity with amount below the win it now price$/ do
  bid(@opportunity.win_it_now_price - 1)
end

Then /^I should win that opportunity automatically$/ do
  steps %Q{
    Then the buyer should be notified that I won that auction
    And that opportunity should have me as the winner
    And bidding should be closed on that opportunity
  }
end

def bid(amount = '100.00')
  click_on "Available Opportunities"
  click_on @opportunity.name
  click_on "Bid Now"
  fill_in :amount, with: amount
  click_on "Submit Bid"
  @bid = Bid.last
end
