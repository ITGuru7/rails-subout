class Opportunity
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :description, type: String
  field :starting_location, type: String
  field :ending_location, type: String
  field :start_date, type: Time
  field :end_date, type: Time
  field :opportunity_type_id, type: Integer
  field :bidding_ends, type: Time
  field :bidding_done, type: Boolean, default: false
  field :quick_winnable, type: Boolean, default: false
  field :win_it_now_price, type: BigDecimal 
  field :winning_bid_id, type: String

  field :for_favorites_only, type: Boolean, default: false

  scope :available, order_by(:created_at => :desc)

  belongs_to :buyer, :class_name => "Company", :inverse_of => :auctions
  has_one :opportunity_type, :class_name => "OpportunityType", :foreign_key => "opportunity_type_id"
  has_one :starting_location, :class_name => "Location", :foreign_key => "starting_location_id"
  has_one :ending_location, :class_name => "Location", :foreign_key => "ending_location_id"
  has_many :bids

  validates_presence_of :buyer_id
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :start_date, :on => :create, :message => "can't be blank"
  validates_presence_of :end_date, :on => :create, :message => "can't be blank"
  validates_presence_of :bidding_ends, :on => :create, :message => "can't be blank"

  def win!(bid_id)
    bid = self.bids.find(bid_id)
    update_attributes(bidding_done: true, winning_bid_id: bid.id)

    Notifier.delay.won_auction_to_supplier(self.id)
    Notifier.delay.won_auction_to_buyer(self.id)
  end

  def winning_bid
    bids.where(id: winning_bid_id).first
  end

  def won?
    winning_bid.present?
  end
end

