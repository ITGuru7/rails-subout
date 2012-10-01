Given /^I have an auction$/ do
  @auction = FactoryGirl.create(:opportunity, :buyer => @buyer)
end

When /^I view my auctions$/ do
  visit auctions_path
end

Then /^I should see that auction$/ do
  page.should have_content(@auction.name)
end
