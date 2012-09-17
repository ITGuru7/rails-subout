When /^I create a new auction$/ do
  click_link "Create a new auction"

  fill_in "Name", with: "New York to Boston"
  fill_in "Description", with: "80 seats"
  fill_in "Starting location", with: "77 Barnhill Rd, West Barnstable, MA 02668"
  fill_in "Ending location", with: "11 Old Toll Rd, West Barnstable, MA 02668"
  fill_in "Start date", with: "2012-12-04"
  fill_in "End date", with: "2012-12-08"
  fill_in "Bidding ends", with: "2012-12-03 3:00 PM"
  click_on "Create Auction"
end

Then /^the need should have been created$/ do
  page.should have_content("The auction has been created")
  
  click_on "My Needs"
  page.should have_content("New York to Boston")
end

Then /^a supplier should not be able to \"win it now\"$/ do
  last_opportunity = Opportunity.last
  last_opportunity.should_not be_quick_winnable
end
