class Contact
  include Mongoid::Document
  field :company_id, type: Integer
  field :vcard, type: String
end
