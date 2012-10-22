FactoryGirl.define do
  factory :event do
    description 'event description'
    association :eventable, :factory => :opportunity
  end
end
