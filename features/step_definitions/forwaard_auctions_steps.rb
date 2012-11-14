Given /^I am signed in as a member company$/ do
  login_as_a_compnay
end

When /^I want to sell a bus named "(.*?)"$/ do |name|
  create_auction(FactoryGirl.build(:forward_auction, name: name))
end

When /^I bid on that opportunity with amount higher the win it now price$/ do
  do_a_bid(@opportunity.win_it_now_price + 1)
end

def login_as_a_compnay
  @company = FactoryGirl.create(:company)
  buyer_user = FactoryGirl.create(:user, :company => @company)
  sign_in(buyer_user)

  @company
end
