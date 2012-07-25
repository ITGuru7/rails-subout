class Company
  include Mongoid::Document
  field :name, type: String
  field :hg_location_id, type: Integer
  field :active, type: Boolean
end
