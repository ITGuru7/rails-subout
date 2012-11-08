class Opportunity
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :description, type: String
  field :starting_location, type: String
  field :ending_location, type: String
  field :start_date, type: Time
  field :end_date, type: Time
  field :bidding_ends, type: Time
  field :bidding_done, type: Boolean, default: false
  field :quick_winnable, type: Boolean, default: false
  field :win_it_now_price, type: BigDecimal
  field :winning_bid_id, type: String
  field :seats, type: Integer
  field :type, type: String
  field :canceled, type: Boolean, default: false

  field :for_favorites_only, type: Boolean, default: false

  scope :available, order_by(:created_at => :desc)
  scope :active, where(:canceled => false)

  belongs_to :buyer, :class_name => "Company", :inverse_of => :auctions

  has_one :event, :as => :eventable
  has_one :starting_location, :class_name => "Location", :foreign_key => "starting_location_id"
  has_one :ending_location, :class_name => "Location", :foreign_key => "ending_location_id"
  has_many :bids

  validates_presence_of :buyer_id
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :start_date, :on => :create, :message => "can't be blank"
  validates_presence_of :end_date, :on => :create, :message => "can't be blank"
  validates_presence_of :bidding_ends, :on => :create, :message => "can't be blank"

  def cancel!
    self.update_attributes(:canceled => true)

    Event.create(:company => self.buyer, :verb => 'canceled', :description => "opportunity canceled", :eventable => self)
  end

  def win!(bid_id)
    bid = self.bids.find(bid_id)

    update_attributes(bidding_done: true, winning_bid_id: bid.id)

    Notifier.delay.won_auction_to_supplier(self.id)
    Notifier.delay.won_auction_to_buyer(self.id)

    Event.create(:company => bid.bidder, :verb => 'bidding_won', :description => "won bidding", :eventable => self)
  end

  def winning_bid
    bids.where(id: winning_bid_id).first
  end

  def winning_bid_amount
    self.winning_bid.try(:amount)
  end

  def serializable_hash(options = nil)
    options ||= {}
    opportunity = self.attributes
    opportunity[:winning_bid_amount] = self.winning_bid_amount
    opportunity[:bids_count] = self.bids_count
    opportunity[:latest_bid_amount] = self.latest_bid_amount
    opportunity[:lowest_bid_amount] = self.lowest_bid_amount
    opportunity[:icon_url] = self.icon_url
    opportunity
  end

  def won?
    winning_bid.present?
  end

  def initiated_by_name
    buyer.name
  end

  def bids_count
    bids.size
  end

  def latest_bid_amount
    bids.latest_amount
  end

  def lowest_bid_amount
    bids.lowest_amount
  end
  
  def winner_name
    if winning_bid_id.present?
      winning_bid.bidder.name
    end
  end
  
  def winning_amount
    winning_bid.try(:amount)
  end
  

  def icon_url
    "img/filters/#{self.type.parameterize}.png"
  end
end

