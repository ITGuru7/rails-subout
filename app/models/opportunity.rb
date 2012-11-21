class Opportunity
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :description, type: String
  field :starting_location, type: String
  field :ending_location, type: String
  field :start_date, type: Date
  field :start_time, type: String
  field :end_date, type: Date
  field :end_time, type: String
  field :bidding_ends, type: Date
  field :bidding_done, type: Boolean, default: false
  field :quick_winnable, type: Boolean, default: false
  field :win_it_now_price, type: BigDecimal
  field :winning_bid_id, type: String
  field :seats, type: Integer
  field :type, type: String
  field :canceled, type: Boolean, default: false
  field :forward_auction, type: Boolean, default: false
  field :expired_notification_sent, type: Boolean, default: false
  field :for_favorites_only, type: Boolean, default: false

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

  def self.send_expired_notification
    where(:bidding_ends.lte => Date.today, :expired_notification_sent => false).each do |auction|
      Notifier.delay.expired_auction_notification(auction.id)
      auction.update_attribute(:expired_notification_sent, true)
    end
  end

  def cancel!
    self.update_attributes(:canceled => true)
  end

  def win!(bid_id)
    bid = self.bids.find(bid_id)

    update_attributes(bidding_done: true, winning_bid_id: bid.id)

    Notifier.delay.won_auction_to_supplier(self.id)
    Notifier.delay.won_auction_to_buyer(self.id)
  end

  def update!(options)
    if bids.any?
      errors.add(:base, "Opportunity cannot be updated if it already has a bid")
    else
      update_attributes(options)
    end
  end

  def winning_bid
    bids.where(id: winning_bid_id).first
  end

  def bidding_ended?
    self.bidding_ends <= Date.today
  end

  def bidable?
    not(self.canceled? || bidding_done? || self.winning_bid_id? || self.bidding_ended?)
  end
end
