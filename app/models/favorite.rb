class Favorite
  include Mongoid::Document
  field :company_id, type: Integer
  field :profile_id, type: Integer
end
