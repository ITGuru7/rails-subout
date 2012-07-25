class Employee
  include Mongoid::Document
  field :company_id, type: Integer
  field :name, type: String
  field :profile_id, type: Integer
  field :contact_id, type: Integer
end
