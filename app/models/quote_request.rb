class QuoteRequest
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::MultiParameterAttributes
  include Mongoid::Token
  include Mongoid::Search

  token field_name: :reference_number, retry_count: 7, length: 7, contains: :upper_alphanumeric

  field :first_name, type: String
  field :last_name, type: String
  field :email, type: String
  field :phone, type: String
  field :vehicle_type, type: String
  field :vehicle_count, type: Integer
  field :passengers, type: Integer

  field :start_location, type: String
  field :start_date, type: Date
  field :start_time, type: String
  field :start_region, type: String

  field :end_location, type: String
  field :end_date, type: Date
  field :end_time, type: String
  field :end_region, type: String

  field :trip_type, type: String
  field :description, type: String

  field :retailer_host, type: String
  field :expired_notification_sent, type: Boolean, default: false

  field :state, type: String

  field :winning_quote_id, type: String
  field :awarded, type: Boolean, default: false
  field :bidding_won_at, type: Time

  attr_accessor :viewer
  
  index created_at: 1
  index start_date: 1

  index vehicle_type: 1
  index trip_type: 1
  index start_region: 1
  index end_region: 1


  belongs_to :retailer
  has_many :quotes
  has_one :opportunity
  belongs_to :winning_quote, :class_name => "Quote"

  search_in :reference_number

  def fulltext
    [reference_number, name, description].join(' ')
  end
  validates :email, presence: true, email: true, confirmation: true
  validates_presence_of :first_name, :last_name, :phone, :start_location, :end_location, :description

  validates :vehicle_count, numericality: { greater_than: 0 }, unless: 'vehicle_count.blank?'
  validates :passengers, numericality: { greater_than: 0 }, unless: 'passengers.blank?'

  TIMEFORMAT = %r(\d{2}\:\d{2})
  validates_presence_of :start_date
  validates :start_date, date: { message: "is invalid date format (mm/dd/yyyy)" }, :if=>"!start_date.blank?"

  validates_presence_of :start_time
  validates_format_of :start_time, message: "is invalid time format (hh:mm)", :with =>TIMEFORMAT, :if=>"!start_time.blank?"

  validates_presence_of :end_date
  validates :end_date, date: { message: "is invalid date format (mm/dd/yyyy)" }, :if=>"!end_date.blank?"

  validates_presence_of :end_time
  validates_format_of :end_time, message: "is invalid time format (hh:mm)", :with =>TIMEFORMAT, :if=>"!end_time.blank?"

  validate :validate_dates
  validate :validate_locations

  VEHICLE_TYPES = ["Sedan",
    "Limo",
    "Party Bus",
    "Limo Bus",
    "Mini Bus",
    "Motorcoach",
    "Double Decker Motorcoach",
    "Executive Coach",
    "Sleeper Bus",
    "School Bus"]

  TRIP_TYPES = [
    "Church Trip",
    "Private Group",
    "Athletic Group",
    "Coroprate Group",
    "Weddings"
  ]

  def recent_quotes
    result = self.quotes.active.recent.map do |quote|
      quote.quote_request = self # to prevent loading opportunity again from db while serializing see BidShortSerializer#comment
      quote
    end
    result.uniq { |quote| quote.quoter_id }
  end

  def name
    "#{first_name}, #{last_name}"
  end

  def quotes_html
    self.recent_quotes.map{|quote| quote.to_html(true)}.join('')
  end

  def status
    if self.winning_quote_id
      "Bidding won"
    elsif self.awarded?
      "Awarded"
    elsif self.bidding_ended?
      "Bidding ended"
    else
      "In progress"
    end
  end

  def bidding_ended?
    self.created_at < 2.days.ago
  end

  def quotable?
    self.bidding_ended? && self.awarded?
  end

  def validate_dates
    unless valid_time?(start_time)
      return
    end

    unless valid_time?(end_time)
      return
    end

    errors.add(:start_date, "cannot be before now") if starts_at <= Time.now
    errors.add(:end_date, "cannot be before the pick up date") if ends_at < starts_at
  end

  def starts_at
    Time.parse("#{self.start_date.to_date} #{self.start_time}")
  end

  def ends_at
    Time.parse("#{self.end_date.to_date} #{self.end_time}")
  end

  def regions
    [self.start_region, self.end_region].compact
  end

  def validate_locations
    unless DEVELOPMENT_MODE
      start_location_info = start_location.blank? ? nil : Geocoder.search(start_location).first
      self.start_region = start_location_info.try(:state)
      errors.add :start_location, "is not valid" unless valid_location?(start_location_info)

      end_location_info = end_location.blank? ? start_location_info : Geocoder.search(end_location).first
      self.end_region = end_location_info.try(:state)
      if !end_location.blank? and !valid_location?(end_location_info)
        errors.add :end_location, "is not valid"
      end
    else
      self.start_region = "Massachusetts" unless self.start_region
      self.end_region = "Massachusetts" unless self.end_region
    end
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

  def valid_location?(location)
    return false if location.blank?
    return false if location.country != "United States"
    return false if location.state.blank?
    true
  end

  def win!(quote_id)
    self.opportunity.awarded = true
    self.opportunity.save(validate: false)

    quote = self.quotes.active.find(quote_id)
    quoter = quote.quoter

    self.awarded = true
    self.state = 'won'
    self.winning_quote_id = quote.id
    self.bidding_won_at = Time.now
    self.save(validate: false) # when poster select winner, the start date validation may be failed

    quote.state = 'won'
    quote.save

    quoter.total_winnings += quote.amount.to_i
    quoter.total_won_bids_count += 1
    quoter.save(validate: false)

    Notifier.delay.won_quote_to_consumer(self.id)
    Notifier.delay.won_quote_to_quoter(self.id) if quoter.notification_items.include?("opportunity-win")
  end

  def notify_companies
    Company.active.each do |company|
      Notifier.delay_for(1.minutes).new_quote_request(self.id, company.id) if company.notification_items.include?("opportunity-new")
    end
  end

  def self.send_expired_notification
    where(:created_at.lte => 2.days.ago, expired_notification_sent: false).each do |quote_request|
      Notifier.delay.expired_quote_request(quote_request.id)
      quote_request.set(:state, 'expired')
      quote_request.set(:expired_notification_sent, true)
    end
  end

  def to_html
    [
      "<strong>Vehicle type:</strong> #{vehicle_type}",
      "<strong>Vehicle count:</strong> #{vehicle_count}",
      "<strong>Passengers:</strong> #{passengers}",
      "<strong>Pick up address:</strong> #{start_location}",
      "<strong>Pick up date:</strong> #{starts_at.to_s(:long)}",
      "<strong>Drop off address:</strong> #{end_location}",
      "<strong>Drop off date:</strong> #{ends_at.to_s(:long)}",
      "<strong>Trip type:</strong> #{trip_type}",
      "<strong>Description:</strong> #{description}",
    ].join("<br>")
  end

end
