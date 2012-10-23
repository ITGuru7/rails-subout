class Bid
  include Mongoid::Document
  include Mongoid::Timestamps

  field :amount, type: BigDecimal

  has_one :event, :as => :eventable

  belongs_to :opportunity
  belongs_to :bidder, :class_name => "Company"

  validates_presence_of :bidder_id, :on => :create, :message => "can't be blank"
  validates_presence_of :opportunity_id, :on => :create, :message => "can't be blank"
  validates_presence_of :amount, :on => :create, :message => "can't be blank"

  def initiated_by_name
    bidder.name
  end

  def type
    'Bid'
  end

  def opportunity_title
    opportunity.name
  end

  def formatted_amount
    formatted_amount = ActionController::Base.helpers.number_to_currency(amount, :unit=>'')
  end
end
