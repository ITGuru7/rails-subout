class BidVehicle
  include Mongoid::Document
  include Mongoid::Timestamps
  embedded_in :bid, inverse_of: :vehicles

  field :year, type: Integer
  field :type, type: String
  field :type_other, type: String
  field :passenger_count, type: Integer
  field :gratuity_included, type: Boolean, default: 0
end
