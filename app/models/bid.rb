class Bid
  include Mongoid::Document
  field :posting_company_id, type: Integer
  field :opportunity_id, type: Integer
  field :amount, type: BigDecimal
  field :active, type: Boolean

  has_one :event, :as => :eventable

  belongs_to :opportunity
  belongs_to :company, :class_name => "Company", :foreign_key => "posting_company_id"

  validates_presence_of :posting_company_id, :on => :create, :message => "can't be blank"
  validates_presence_of :opportunity_id, :on => :create, :message => "can't be blank"
  validates_presence_of :amount, :on => :create, :message => "can't be blank"

end
