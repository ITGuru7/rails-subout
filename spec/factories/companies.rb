FactoryGirl.define do
  factory :company do
    name 'Boston Bus' 
    sequence(:email) {|n| "company#{n}@example.com" }
    zip_code '02634'
    street_address '33 Comm Ave'
  end
end
