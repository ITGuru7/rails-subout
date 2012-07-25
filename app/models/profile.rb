class Profile
  include Mongoid::Document
  field :name, type: String
  field :contact_id, type: Integer
  field :company_id, type: Integer
  field :active, type: Boolean
end
