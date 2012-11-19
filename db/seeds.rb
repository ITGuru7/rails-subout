# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

[Company, Contact, Location, Opportunity, Bid, Event].each do |model|
  model.all.destroy_all

  collection = model.collection_name
  puts "importing #{collection}.json"
  puts `mongoimport --db subout_development --collection #{collection} --upsert --file db/seeds/#{collection}.json`
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
  company = Company.where(:name => company_name).first
  FactoryGirl.create(:user, :email => user_email, :company => company, :password => 'password', :password_confirmation => 'password' )
end
