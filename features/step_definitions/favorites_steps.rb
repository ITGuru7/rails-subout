Given /^a supplier exists called "(.*?)"$/ do |name|
  @supplier = FactoryGirl.create(:company, :name => name, :email => 'thomas@bostonbus.com')
end

When /^I add that supplier as one of my favorite suppliers$/ do
  click_on "Favorite suppliers"
  fill_in "Email", :with => @supplier.email
  click_on "Find Supplier"
  page.should have_content @supplier.name
  click_on "Add to my favorite suppliers"
#  page.should have_content 'Invitation sent.' 
end

Then /^that supplier should be in my list of favorite suppliers$/ do
  @buyer.reload.favorite_suppliers.should include(@supplier)
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

Then /^that supplier should receive a favorite invitation email$/ do
  step %["#{@supplier.email}" should receive an email]
end

When /^the supplier accpets the invitation$/ do
  step %{I open the email}
  step %{I click the first link in the email}
end


When /^I try to add "(.*?)" with email "(.*?)" as one of my favorite suppliers but don't find it$/ do |arg1, email|
  click_on "Favorite suppliers"
  fill_in "Email", :with => email
  click_on "Find Supplier"
  page.should have_content "That supplier was not found"
end

When /^I add "(.*?)" to my favorites as a new guest supplier with email "(.*?)"$/ do |supplier_name, email|
  click_on "Add to my favorite as a new guest supplier"
  fill_in 'Supplier Company Name', :with => supplier_name
  find_field('Send Invitation To').value.should == email
  find_field('Custom message').value.should == "\nHi <supplier_name>, #{@buyer.name} would to add you as a favorite supplier on Subout."
  fill_in 'Custom message', :with => "Hey Tom, It's Bob.  I'm trying to buy this thing from you.  Please sign up."
  click_on "Send"
  @favorite_invitation = FavoriteInvitation.last
end

Then /^"(.*?)" should receive a new guest supplier invitation email$/ do |email|
  step %["#{email}" should receive an email]
end

When /^fills out their supplier details$/ do
  find_field('Company name').value.should == @favorite_invitation.supplier_name
  find_field('Company email').value.should == @favorite_invitation.supplier_email

  fill_in('Password', :with => 'password1') 
  fill_in('Password confirmation', :with => 'password1') 
  fill_in('Street address', :with => '33 Comm Ave') 
  fill_in('Zip code', :with => '02634') 

  click_on('Create Company')

  @supplier = Company.last
end

Then /^that supplier should be able to bid on my auctions$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^that supplier should be able to see other auctions but not bid on them$/ do
  pending # express the regexp above with the code you wish you had
end
 
