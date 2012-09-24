FactoryGirl.define do
  factory :favorite_invitation do
    association :buyer, factory: :company
    association :supplier, factory: :company
  end
end
