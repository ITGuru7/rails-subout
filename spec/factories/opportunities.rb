FactoryGirl.define do
  factory :opportunity do
    association :buyer, factory: :company
    name "New York to Boston"
    description "80 seats"
    starting_location "77 Barnhill Rd, West Barnstable, MA 02668"
    ending_location "11 Old Toll Rd, West Barnstable, MA 02668"
    start_date { 1.month.from_now }
    end_date { 2.months.from_now}
    bidding_ends { 2.weeks.from_now }
    quick_winnable false
  end
end
