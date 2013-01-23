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
  field :bidding_duration_hrs, type: String
  field :bidding_ends_at, type: DateTime
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

  scope :active, -> { where(canceled: false) }
  scope :recent, -> { desc(:created_at) }

  belongs_to :buyer, class_name: "Company", inverse_of: :auctions

  has_one :event, as: :eventable
  has_many :bids

  validates :win_it_now_price, numericality: { greater_than: 0 }, unless: 'win_it_now_price.blank?'
  validates :bidding_duration_hrs, numericality: { greater_than: 0 }, presence: true
  validates_presence_of :buyer_id
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :start_date
  validates_presence_of :end_date
  validates_presence_of :start_location
  validate :validate_locations
  validate :validate_buyer_region
  validate :validate_start_and_end_date
  validate :validate_win_it_now_price

  before_save :set_bidding_ends_at, unless: 'self.canceled'

  def self.send_expired_notification
    where(:bidding_ends_at.lte => Time.now, expired_notification_sent: false).each do |opportunity|
      Notifier.delay.expired_auction_notification(opportunity.id)
      opportunity.update_attribute(:expired_notification_sent, true)
    end
  end

  def regions
    [self.start_region, self.end_region]
  end

  def cancel!
    self.update_attributes(canceled: true, bidding_ends_at: Time.now)
  end

  def win!(bid_id)
    bid = self.bids.find(bid_id)

    update_attributes(bidding_done: true, winning_bid_id: bid.id)

    Notifier.delay.won_auction_to_supplier(self.id)
    Notifier.delay.won_auction_to_buyer(self.id)
    self.bids.ne(id: winning_bid_id).each do |bid|
      Notifier.delay.finished_auction_to_bidder(self.id, bid.id)
    end
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
    self.bidding_ends_at <= Time.now
  end

  def bidable?
    not(self.canceled? || bidding_done? || self.winning_bid_id? || self.bidding_ended?)
  end

  def validate_locations
    unless DEVELOPMENT_MODE
      start_location_info = start_location.blank? ? nil : Geocoder.search(start_location).first
      self.start_region = start_location_info.try(:state)
      errors.add :start_location, "is not valid, please try again" unless valid_location?(start_location_info)

      end_location_info = end_location.blank? ? start_location_info : Geocoder.search(end_location).first
      self.end_region = end_location_info.try(:state)
      if !end_location.blank? and !valid_location?(end_location_info)
        errors.add :end_location, "is not valid, please try again"
      end
    else
      self.start_region = "Massachusetts" unless self.start_region
      self.end_region = "Massachusetts" unless self.end_region
    end
  end

  def validate_buyer_region
    return unless buyer
    unless buyer.subscribed?(regions) || DEVELOPMENT_MODE
      errors.add :buyer_id, "cannot create an opportunity within this region"
    end
  end

  def fulltext
    [reference_number, name, description].join(' ')
  end

  def valid_location?(location)
    return false if location.blank?
    return false if location.country != "United States"
    return false if location.state.blank?
    true
  end

  def starts_at
    Time.parse("#{self.start_date} #{self.start_time}")
  end

  def ends_at
    Time.parse("#{self.end_date} #{self.end_time}")
  end

  def editable?
    return false if self.canceled?
    not(self.bids.exists?)
  end

  def recent_bids
    self.bids.recent
  end

  def status
    if self.canceled?
      "Canceled"
    elsif self.winning_bid_id
      "Bidding won"
    elsif self.bidding_ended?
      "Bidding ended"
    else
      "In progress"
    end
  end

  private

  def set_bidding_ends_at
    created_time = self.created_at || Time.now
    self.bidding_ends_at = created_time + self.bidding_duration_hrs.to_i.hours
  end

  def valid_time?(time)
    return false unless time
    begin
      Time.parse(time)
      true
    rescue ArgumentError
      false
    end
  end

  def validate_start_and_end_date
    unless valid_time?(start_time)
      errors.add(:start_time, "is invalid")
      return
    end

    unless valid_time?(end_time)
      errors.add(:end_time, "is invalid")
      return
    end

    errors.add(:start_date, "cannot be before now") if starts_at <= Time.now
    errors.add(:end_date, "cannot be before the start date") if ends_at < starts_at
  end

  def validate_win_it_now_price
    errors.add(:win_it_now_price, "cannot be blank in case 'Win it now?' option is enabled.") if self.quick_winnable && self.win_it_now_price.blank?
  end
end
