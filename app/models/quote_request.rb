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
  field :start_date, type: DateTime
  field :start_region, type: String

  field :end_location, type: String
  field :end_date, type: DateTime
  field :end_region, type: String

  field :trip_type, type: String
  field :description, type: String

  field :consumer_host, type: String

  belongs_to :consumer

  validates :vehicle_count, numericality: { greater_than: 0 }, unless: 'vehicle_count.blank?'
  validates :passengers, numericality: { greater_than: 0 }, unless: 'passengers.blank?'
  validate :validate_dates
  validate :validate_locations

  validates_presence_of :first_name, :last_name, :email, :phone, :start_location, :start_date, :end_location, :end_date, :description

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

  def validate_dates
    errors.add(:start_date, "cannot be before now") if self.start_date && (self.start_date <= Time.now)
    errors.add(:end_date, "cannot be before the pick up date") if self.end_date && (self.end_date < self.start_date)
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

end
