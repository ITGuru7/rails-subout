class Favorite
  include Mongoid::Document
  field :company_id, type: Integer
  field :favorite_id, type: Integer

  belongs_to :company, :class_name => "Company", :foreign_key => "company_id"
  has_one :favorite, :class_name => "Company", :foreign_key => "favorite_id"

  validates_presence_of :company_id, :on => :create, :message => "can't be blank"
  validates_presence_of :favorite_id, :on => :create, :message => "can't be blank"
end
