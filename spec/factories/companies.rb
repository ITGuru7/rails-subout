FactoryGirl.define do
  factory :company, aliases: [:supplier] do
    name 'Boston Bus' 
    sequence(:email) {|n| "company#{n}@example.com" }
    zip_code '02634'
    street_address '33 Comm Ave'
    created_from_invitation_id 'invitation_id'

    factory :buyer, aliases: [:member_supplier] do
      member true
    end
  end
end
