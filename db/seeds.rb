# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


#ORM.observers.disable :event_observer

require 'test_data_generator'

def create_data
  national_companies = [
    { company_name: 'Boston Express Bus Inc.',    email: 'steve@bostonbus.com' },
    { company_name: 'Valley Bus Coaches, Llc',    email: 'ed@valleybus.com' },
    { company_name: 'Peter Pan Bus Lines, Inc.',  email: 'peter@notpeterpanbus.com' }
  ]

  state_by_state_companies = [
    { company_name: 'Phoenix Bus Inc',                  email: 'tom@phoenixbus.com' },
    { company_name: 'Hyannis Bus Inc',                  email: 'tom@hyannisbus.com' },
    { company_name: 'Barnstable Bus Inc',               email: 'tom@barnstablebus.com' }
  ]

  data_generator = TestDataGenerator.new
  companies = data_generator.create_companies(national_companies, "national")
  companies = data_generator.create_companies(state_by_state_companies, "state-by-state")
  # TestDataGenerator.generate_opportunities
  # TestDataGenerator.generate_bids
end

if Rails.env == "production"
  puts "Cannot run db seed on production"
else
  create_data
end
