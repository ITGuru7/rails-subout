class Bid
  include Mongoid::Document
  field :opportunity_id, type: Integer
  field :amount, type: BigDecimal
  field :active, type: Boolean

  has_one :event, :as => :eventable

  belongs_to :opportunity
  belongs_to :bidder, :class_name => "Company"

  validates_presence_of :bidder_id, :on => :create, :message => "can't be blank"
  validates_presence_of :opportunity_id, :on => :create, :message => "can't be blank"
  validates_presence_of :amount, :on => :create, :message => "can't be blank"

  def description
    "#{company.name} #{ammount}"
  end
  
end
