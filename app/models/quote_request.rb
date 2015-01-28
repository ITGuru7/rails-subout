class QuoteRequest
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::MultiParameterAttributes

  field :first_name, type: String
  field :last_name, type: String
  field :email, type: String
  field :phone, type: String
  field :vehicle_type, type: String
  field :vehicle_count, type: Integer
  field :passengers, type: Integer

  field :pick_up_location, type: String
  field :pick_up_date, type: Date

  field :drop_off_location, type: String
  field :drop_off_date, type: Date

  field :trip_type, type: String
  field :description, type: String

  validates :vehicle_count, numericality: { greater_than: 0 }, unless: 'vehicle_count.blank?'
  validates :passengers, numericality: { greater_than: 0 }, unless: 'passengers.blank?'

  validates_presence_of :first_name, :last_name, :email, :phone, :pick_up_location, :pick_up_date, :drop_off_location, :drop_off_date, :description


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

  def validate_start_and_end_date
    errors.add(:pick_up_date, "cannot be before now") if self.pick_up_date <= Time.now
    errors.add(:drop_off_date, "cannot be before the pick up date") if self.drop_off_date < self.pick_up_date
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

end
