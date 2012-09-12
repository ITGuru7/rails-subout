Given /^a user exist and is logged in$/ do
  @current_user = FactoryGirl.create(:user, email: "abc@example.com", password: "password1")

  visit new_user_session_path

  fill_in "Email", with: "abc@example.com"
  fill_in "Password", with: "password1"
  click_on "Sign in"
  
  page.should have_content("Sign out")
end

Given /^a user exists with email: "(.*?)" and password: "(.*?)"$/ do |email, password|
  c = Company.create(:name => 'foo')
  u = User.create!(email: email, password: password, authentication_token: "aMVyrz8AWGrdWQGqgy8G")
  u.company = c
  u.save
end

Given /^I am on the sign in page$/ do
  visit "/users/sign_in"
end

Given /^I fill in "(.*?)" with "(.*?)"$/ do |label, value|
  fill_in label, with: value
end

When /^(?:|I )press "([^"]*)"(?: within "([^"]*)")?$/ do |button, selector|
  click_button(button)
end

Then /^(?:|I )should see "([^"]*)"(?: within "([^"]*)")?$/ do |text, selector|
  page.should have_content(text)
end
