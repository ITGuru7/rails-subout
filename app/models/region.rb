class Region
  include Mongoid::Document
  field :region_type_id, type: Integer
  field :company_id, type: Integer
end
