# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


ORM.observers.disable :event_observer

demo_companies = {
  'Diversified Transportation Ltd.' => 'suboutdev@gmail.com',
  'Valley Bus Coaches, Llc' => 'ed@valley_bus.com',
  'Peter Pan Bus Lines, Inc.' => 'peter@peterpan_bus.com',
  'Phoenix Bus Inc' => 'tom@phoenix_bus.com',
  'Boston Express Bus Inc.' => 'steve@boston_bus.com'
}

demo_addresses = 
  ["540 Main St, Hyannis, MA, 02630", 
  "2325 Maryland Road, Willow Grove, PA 19090",
  "881 7th Avenue  New York, NY 10019",
  "1084 Shennecossett Road, Groton, CT 06340",
  "1668 Daniel Webster Highway  North Woodstock, NH 03262",
  "Route 1 South Ogunquit, ME 03907",
  "1404 Wheelock Road, Danville, VT 05828",
  "70 Washington Road  Princeton, NJ 08540",
  "3346 U.S. 301, Hamer, SC 29547",
  "205 14th St NW, Charlottesville, VA 22903",
  "1600 Pennsylvania Avenue NW Washington DC 20500",
  "451 Bellevue Road, Newark, DE 19713",
  "1 Thames St, Newport, RI, 02840"
]

demo_opportunities = [
  "Vehicle Needed", "Vehicle for Hire", "Special", "Emergency", "Part"
]


def decent_name(opportunity_type)
  demo_vehicle_types = [
  "4 Pass Sedan", "6 Pass Limo", "8 Pass Limo", "10 Pass Limo",
  "14 Pass SUV", "18 Pass SUV",
  "49 Pass Luxury Coach", 
  "56 Pass Luxury Coach", 
  "57 Pass Luxury Coach", 
  "58 Pass Luxury Coach", 
  "59 Pass Luxury Coach", 
  "60 Pass Luxury Coach", 
  "61 Pass Luxury Coach", 
  "55 Pass Luxury Coach", 
  "54 Pass Luxury Coach", 
  "49 Pass Luxury Coach", 
  "49 Pass Luxury Coach", 
  "49 Pass Luxury Coach", 
  "18 Pass Mini Bus",
  "24 Pass Mini Bus",
  "28 Pass Mini Bus",
  "30 Pass Mini Bus",
  "35 Pass Mini Bus"
]

demo_part = [
  "mirror", "tire", "seat", "brake light", "fuel pump"
]

  case opportunity_type
    when "Vehicle Needed"
       "#{Faker::Address.city}, #{demo_vehicle_types.shuffle.first}, #{rand(10).days.from_now.to_formatted_s(:short) }"
    when "Vehicle for Hire"
      "#{Faker::Address.city}, #{demo_vehicle_types.shuffle.first}"
    when "Special"
      "#{Faker::Address.city}, #{demo_vehicle_types.shuffle.first}, #{rand(100)}% OFF"
    when "Emergency"
      "#{Faker::Address.city}, Broken down on I#{rand(9)}95, mile #{rand(100)}"
    when "Part"
        "#{Faker::Address.city}, Need a #{demo_part.shuffle.first}"    
   end 
end
[Company, Opportunity, Bid, Event].each do |model|
  model.all.destroy_all
end


User.all.destroy_all
demo_companies.each do |company_name, user_email|
  subscription = GatewaySubscription.create(:product_handle => "national-service")
  company = Company.create(
    :email => user_email,
    :regions => [:all],
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
  25.times do
    opp_type = demo_opportunities.shuffle.first
    opportunity = Opportunity.create(
      :name =>decent_name(opp_type),
      :description => "#{rand(100)} seats",
      :start_location => demo_addresses.shuffle.first,
      :start_date => rand(10).days.from_now,
      :end_date => 12.days.from_now,
      :bidding_ends => 1.days.from_now,
      :quick_winnable => false,
      :type => opp_type,
      :buyer_id => company.id,
      :bidding_duration_hrs => 24)
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
