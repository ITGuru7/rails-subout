FactoryGirl.define do
  factory :bid do
    association :bidder, :factory => :supplier
    opportunity
    amount 10
  end
end
