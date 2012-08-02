class Company
  include Mongoid::Document
  field :name, type: String
  field :hq_location_id, type: Integer
  field :active, type: Boolean
end
