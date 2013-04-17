class Opportunity
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Token
  include Mongoid::Search

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
  field :bidding_ends_at, type: Time
  field :bidding_done, type: Boolean, default: false
  field :quick_winnable, type: Boolean, default: false
  field :win_it_now_price, type: Money
  field :winning_bid_id, type: String
  field :seats, type: Integer
  field :type, type: String
  field :vehicle_type, type: String
  field :trip_type, type: String
  field :canceled, type: Boolean, default: false
  field :forward_auction, type: Boolean, default: false
  field :expired_notification_sent, type: Boolean, default: false
  field :for_favorites_only, type: Boolean, default: false
  field :image_id
  field :tracking_id
  field :contact_phone, type: String
  field :value, type: Money, default: 0
  field :reserve_amount, type: Integer
  field :bidding_won_at, type: Time
  field :ada_required, type: Boolean, default: false

  #if the regions have been changed we keep track of the old ones here so we know who's already been notified
  field :notified_regions, type: Array, default: [] 
  field :favorites_notified, type: Boolean, default: false
  attr_accessor :viewer

  scope :active, -> { where(canceled: false) }
  scope :recent, -> { desc(:created_at) }
  scope :won, -> { where(:winning_bid_id.ne => nil) }
  scope :by_region, ->(region) { where(start_region: region) }

  belongs_to :buyer, class_name: "Company", inverse_of: :auctions, counter_cache: :auctions_count

  has_one :event, as: :eventable
  has_many :bids
  embeds_many :comments
  belongs_to :winning_bid, :class_name => "Bid"

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
  validate :validate_reseve_amount_and_win_it_now_price
  validates :vehicle_type, inclusion: { in: [nil, "Sedan", "Limo", "Party Bus", "Limo Bus", "Mini Bus", "Motorcoach", "Double Decker Motorcoach", "Executive Coach", "Sleeper Bus"] }
  validates :trip_type, inclusion: { in: [nil, "One way", "Round trip", "Over the road"] }

  before_save :set_bidding_ends_at, unless: 'self.canceled'

  search_in :reference_number, :name, :description

  paginates_per 30

  def companies_to_notify
    options = []
    if self.for_favorites_only?
      options << {:id.in => self.buyer.favorite_supplier_ids}
    else
      options << {:subscription_plan => 'subout-national-service'}
      options << {:subscription_plan => 'subout-partner'}
      options << {:regions.in => regions}
    end
    companies = Company.where(locked_at: nil).any_of(*options).excludes(id: self.buyer_id, notification_type: 'None') - notified_companies
    companies.select { |c| notify_to_vehicle_owner?(c.vehicles) }
  end

  def notified_companies
    options = []
    if notified_regions.present?
      options << {:subscription_plan => 'subout-national-service'}
      options << {:subscription_plan => 'subout-partner'}
    end
    options << {:regions.in => notified_regions}
    options << {:id.in => self.buyer.favorite_supplier_ids} if favorites_notified?
    Company.any_of(*options)
  end

  def notify_companies(event_type)
    companies_to_notify.each do |company|
      Notifier.delay_for(1.minutes).new_opportunity(self.id, company.id)
      Sms.new_opportunity(self, company) if company.cell_phone.present? && self.emergency?
    end

    if self.for_favorites_only?
      self.set(:favorites_notified, true)
    else
      notified_regions = (self.regions + self.notified_regions).uniq
      self.set(:notified_regions, notified_regions) 
    end
  end

  def emergency?
    self.type == "Emergency"
  end

  def self.send_expired_notification
    where(:bidding_ends_at.lte => Time.now, expired_notification_sent: false).each do |opportunity|
      Notifier.delay.expired_auction_notification(opportunity.id)
      opportunity.set(:expired_notification_sent, true)
    end
  end

  def regions
    [self.start_region, self.end_region]
  end

  def cancel!
    self.update_attributes(canceled: true, bidding_ends_at: Time.now)
  end

  def win!(bid_id)
    bid = self.bids.active.find(bid_id)

    self.bidding_done = true
    self.winning_bid_id = bid.id
    self.value = bid.amount
    self.bidding_won_at = Time.now
    self.save(validate: false) # when poster select winner, the start date validation may be failed

    self.buyer.inc(:total_sales, bid.amount)
    bid.bidder.inc(:total_winnings, bid.amount)
    bid.bidder.inc(:total_won_bids_count, 1)

    Notifier.delay.won_auction_to_buyer(self.id)

    Notifier.delay.won_auction_to_supplier(self.id)
    bid_loser_ids.each do |bidder_id|
      Notifier.delay.finished_auction_to_bidder(self.id, bidder_id)
    end
  end

  def bid_loser_ids
    bidder_ids = self.bids.active.map(&:bidder_id)
    bidder_ids.reject! { |bidder_id| bidder_id == winning_bid.bidder_id }
    bidder_ids.uniq
  end

  def update!(options)
    if bids.active.any?
      errors.add(:base, "Opportunity cannot be updated if it already has a bid")
    else
      update_attributes(options)
    end
  end

  def winning_bid
    Bid.where(id: winning_bid_id, opportunity_id: id).first
  end

  def leading_bid_amount
    if forward_auction
      leading_bid, second_leading_bid = bids.active.sort_by { |b| -b.bidding_limit_amount }
      [second_leading_bid.bidding_limit_amount + 1, leading_bid.bidding_limit_amount].min
    else
      leading_bid, second_leading_bid = bids.active.sort_by { |b| b.bidding_limit_amount }
      [second_leading_bid.bidding_limit_amount - 1, leading_bid.bidding_limit_amount].max
    end
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
    not(self.bids.active.exists?)
  end

  def recent_bids
    result = self.bids.active.recent.map do |bid|
      bid.opportunity = self # to prevent loading opportunity again from db while serializing see BidShortSerializer#comment
      bid
    end
    result.uniq { |bid| bid.bidder_id }
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

  def won?
    self.winning_bid_id.present?
  end

  def update_value!
    if self.won?
      value = self.winning_bid.amount 
    else
      value = forward_auction? ? highest_bid_amount : lowest_bid_amount
      value ||= 0
    end
    self.set(:value, value.to_i * 100)
  end

  def lowest_bid_amount
    self.bids.active.sort_by { |b| b.amount }.first.try(:amount)
  end

  def highest_bid_amount
    self.bids.active.sort_by { |b| -b.amount }.first.try(:amount)
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

  def validate_reseve_amount_and_win_it_now_price
    return unless self.reserve_amount.present? and self.win_it_now_price.present?

    if self.forward_auction?
      errors.add(:reserve_amount, "cannot be more than win it now price") if self.reserve_amount > self.win_it_now_price
    else
      errors.add(:reserve_amount, "cannot be less than win it now price") if self.reserve_amount < self.win_it_now_price
    end
  end

  def notify_to_vehicle_owner?(vehicles)
    return true if vehicles.blank?
    return true if vehicle_type.blank?
    vehicles.include?(vehicle_type)
  end
end
