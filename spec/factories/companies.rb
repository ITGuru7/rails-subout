FactoryGirl.define do
  factory :company do
    name 'Boston Bus' 
    sequence(:email) {|n| "company#{n}@example.com" }
  end
end
