class MobileKey
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  field :key
  field :device_type #iOS, Android
end
