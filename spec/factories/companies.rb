FactoryGirl.define do
  factory :company, aliases: [:supplier] do
    sequence(:name) {|n| "Company Name #{n}" }
    sequence(:abbreviated_name) {|n| "AN-#{n}" }
    sequence(:email) {|n| "company#{n}@example.com" }
    zip_code '02634'
    street_address '33 Comm Ave'
    created_from_subscription {FactoryGirl.create(:gateway_subscription)}
    subscription_plan "national-service"

    factory :buyer, aliases: [:member_supplier] do
      member true
    end

    factory :ca_company do
      after :create do |company|
        company.regions = ['CA']
        company.subscription_plan = 'state-by-state-service' 
        company.save(callbacks: false)
      end
    end
  end
end
