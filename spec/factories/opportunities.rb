FactoryGirl.define do
  factory :opportunity do
    company 
    name "New York to Boston"
    description "80 seats"
    starting_location "77 Barnhill Rd, West Barnstable, MA 02668"
    ending_location "11 Old Toll Rd, West Barnstable, MA 02668"
    start_date "2012-12-04"
    end_date "2012-12-08"
    bidding_ends "2012-12-03 3:00 PM"
  end
end
