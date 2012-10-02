When /^I create a new auction$/ do
  create_auction(FactoryGirl.build(:opportunity))
end

When /^I create a new quick winnable auction$/ do
  create_auction(FactoryGirl.build(:opportunity, :quick_winnable => true))
end

When /^I create a new auction for favorites only$/ do
  create_auction(FactoryGirl.build(:opportunity, :for_favorites_only => true))
end 

Then /^the auction should have been created$/ do
  page.should have_content("The auction has been created")
  
  click_on "My Auctions"
  page.should have_content("New York to Boston")
end

Then /^a supplier should not be able to \"win it now\"$/ do
  last_opportunity.should_not be_quick_winnable
end

Then /^a supplier should be able to \"win it now\"$/ do
  last_opportunity.should be_quick_winnable
end

Then /^only my favorites should see the opportunity$/ do
  last_opportunity.should be_for_favorites_only
end


def last_opportunity
  Opportunity.last
end

def create_auction(opportunity)
  click_link "Create a new auction"

  fill_in "Name", with: opportunity.name
  fill_in "Description", with: opportunity.description
  fill_in "Starting location", with: opportunity.starting_location
  fill_in "Ending location", with: opportunity.ending_location
  fill_in "Start date", with: opportunity.start_date
  fill_in "End date", with: opportunity.end_date
  fill_in "Bidding ends", with: opportunity.bidding_ends
  check "Quick winnable" if opportunity.quick_winnable?
  check "For favorites only" if opportunity.for_favorites_only?
  click_on "Create Auction"
end
