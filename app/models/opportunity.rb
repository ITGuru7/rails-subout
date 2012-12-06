class Opportunity
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Token

  token field_name: :reference_number, retry: 5, length: 7, contains: :upper_alphanumeric

  field :name, type: String
  field :description, type: String
  field :start_location, type: String
  field :end_location, type: String
  field :start_region
  field :end_region
  field :start_date, type: Date
  field :start_time, type: String
  field :end_date, type: Date
  field :end_time, type: String
  field :bidding_duration_hrs
  #field :bidding_ends_at, type: DateTime
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
  field :image_id
  field :tracking_id

  scope :active, where(:canceled => false)

  belongs_to :buyer, :class_name => "Company", :inverse_of => :auctions

  has_one :event, :as => :eventable
  has_many :bids

  validates_presence_of :buyer_id
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :start_date
  validates_presence_of :end_date
  validates_presence_of :bidding_duration_hrs
  validates_presence_of :start_location
  validate :validate_locations
  validate :validate_buyer_region

  def self.send_expired_notification
    where(:created_at.lte => (Time.now - bidding_duration_hrs.to_i.hours), :expired_notification_sent => false).each do |auction|
      Notifier.delay.expired_auction_notification(auction.id)
      auction.update_attribute(:expired_notification_sent, true)
    end
  end

  def regions
    [self.start_region, self.end_region]
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
    self.bidding_ends_at <= Date.today
  end

  def bidable?
    not(self.canceled? || bidding_done? || self.winning_bid_id? || self.bidding_ended?)
  end

  def validate_locations
    self.start_region = Geocoder.search(start_location).first.try(:state)

    if end_location.blank?
      self.end_region = self.start_region
    else
      self.end_region = Geocoder.search(end_location).first.try(:state)
      errors.add :end_location, "is invalid" unless self.end_region
    end

    errors.add :start_location, "is invalid" unless self.start_region
  end

  def validate_buyer_region
    unless buyer.subscribed?(regions)
      errors.add :buyer_id, "cannot create an opportunity within this region"
    end
  end

  def bidding_ends_at
    created_at + bidding_duration_hrs.to_i.hours
  end
end
