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
  field :contact_phone, type: String

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
    start_location_info = start_location.blank? ? nil : Geocoder.search(start_location).first
    self.start_region = start_location_info.try(:state)
    errors.add :start_location, "is not valid, please try again" unless valid_location?(start_location_info)

    end_location_info = end_location.blank? ? start_location_info : Geocoder.search(end_location).first
    self.end_region = end_location_info.try(:state)
    if !end_location.blank? and !valid_location?(end_location_info)
      errors.add :end_location, "is not valid, please try again"
    end
  end

  def validate_buyer_region
    unless buyer.subscribed?(regions)
      errors.add :buyer_id, "cannot create an opportunity within this region"
    end
  end

  def bidding_ends_at
    created_at + bidding_duration_hrs.to_i.hours
  end

  def fulltext
    [name, description].join(' ')
  end

  def valid_location?(location)
    return false if location.blank?
    return false if location.country != "United States"
    return false if location.state.blank?
    true
  end
end
