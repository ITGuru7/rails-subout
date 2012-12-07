# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

[Company, Opportunity, Bid, Event].each do |model|
  model.all.destroy_all
end

demo_companies = {
  'Diversified Transportation Ltd.' => 'suboutdev@gmail.com',
  'Valley Bus Coaches, Llc' => 'ed@valley_bus.com',
  'Peter Pan Bus Lines, Inc.' => 'peter@peterpan_bus.com',
  'Phoenix Bus Inc' => 'tom@phoenix_bus.com',
  'Boston Express Bus Inc.' => 'steve@boston_bus.com'
}

User.all.destroy_all
demo_companies.each do |company_name, user_email|
  subscription = GatewaySubscription.create(:product_handle => "national-plan")
  company = Company.create(
    :email => user_email,
    :regions => ["NY", "CT", "MA", "NJ", "NH"],
    :abbreviated_name => company_name.squeeze[0..5],
    :name => company_name,
    :contact_name => Faker::Name.name,
    :fleet_size => "7 65 PAX bus",
    :since => "1975", 
    :owner => Faker::Name.name,
    :contact_phone => Faker::PhoneNumber.phone_number,
    :tpa => rand(99999999).to_s,
    :website => Faker::Internet.http_url,
    :prelaunch => false,
    :created_from_subscription => subscription.id
  )
  User.create(:email => user_email, :company => company, :password => 'password', :password_confirmation => 'password' )
  rand(10).times do
    opportunity = Opportunity.create(
      :name => "#{Faker::Address.city} to #{Faker::Address.city}",
      :description => "#{rand(100)} seats",
      :starting_location => "#{Faker::Address.street_address}, #{Faker::Address.city}, #{Faker::Address.us_state_abbr}, #{Faker::Address.zip_code}",
      :ending_location => "#{Faker::Address.street_address}, #{Faker::Address.city}, #{Faker::Address.us_state_abbr}, #{Faker::Address.zip_code}",
      :start_date => rand(10).days.from_now,
      :end_date => 12.days.from_now,
      :bidding_ends => 1.days.from_now,
      :quick_winnable => false,
      :type => 'Vehicle Needed',
      :buyer_id => company.id,
      :regions => [Faker::Address.us_state])
    puts opportunity.errors.inspect unless opportunity.valid?
  end 
end

demo_companies.each do |company_name, user_email|
  company = Company.where(:email => user_email).first
  10.times do 
    print(".")
    o = Opportunity.all.shuffle.first
    b = Bid.create(
      :amount => rand(1000),
      :opportunity_id => o.id,
      :bidder_id => company.id
    )
  end
end
