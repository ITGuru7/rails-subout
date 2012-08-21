class Contact
  include Mongoid::Document
  field :company_id, type: Integer
  field :phone, type: String
  field :phone2, type: String
  field :twenty_four_hour_line, type: String
  field :fax, type: String
  field :contact_name, type: String
  field :email1, type: String
  field :email2, type: String
  field :email3, type: String
  field :location_id, type: String
  field :quest, type: String
  field :survey_result, type: String
  field :contact_name, type: String
  


  has_one :location, :class_name => "Location", :foreign_key => "location_id"
  belongs_to :company

end
