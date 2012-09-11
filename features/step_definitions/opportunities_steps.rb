Given /^a user exist and logged in$/ do
  @current_user = FactoryGirl.create(:user, email: "abc@example.com", password: "password1")

  visit new_user_session_path

  fill_in "Email", with: "abc@example.com"
  fill_in "Password", with: "password1"
  click_on "Sign in"
  
  page.should have_content("Sign out")
end

When /^I submit a new opportunity$/ do
  click_link "Create a new opportunity"

  fill_in "Name", with: "New York to Boston"
  fill_in "Description", with: "80 seats"
  fill_in "Starting location", with: "77 Barnhill Rd, West Barnstable, MA 02668"
  fill_in "Ending location", with: "11 Old Toll Rd, West Barnstable, MA 02668"
  fill_in "Start date", with: "2012-12-04"
  fill_in "End date", with: "2012-12-08"
  fill_in "Bidding ends", with: "2012-12-03 3:00 PM"
  click_on "Create Opportunity"
end
