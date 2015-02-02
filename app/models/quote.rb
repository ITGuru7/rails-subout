class Quote
  include Mongoid::Document
  include Mongoid::Timestamps

  field :amount, type: Money
  field :comment, type: String

  field :vehicle_count, type: Integer, default: 1

  paginates_per 30

  embeds_many :vehicles, class_name: 'BidVehicle'

  belongs_to :quote_request, :inverse_of => :quotes
  belongs_to :quoter, class_name: "Company", counter_cache: :bids_count


  validates_presence_of :quoter_id, on: :create, message: "can't be blank"
  validates_presence_of :quote_request_id, on: :create, message: "can't be blank"
  validates_presence_of :amount, on: :create, message: "can't be blank"
  validates :amount, numericality: { greater_than: 0 }
  validates :vehicle_count, numericality: { greater_than: 0}, unless: 'vehicle_count.blank?'

  validate :validate_quote_request_quotable, on: :create
  validate :validate_quotable_by_quoter, on: :create
 
  validate :validate_dot_number_of_quoter, on: :create
  validate :vehicle_count_quotable, on: :create

  validates :comment, length: { maximum: 255 }

  scope :recent, -> { desc(:created_at) }
  scope :by_amount, -> { asc(:amount) }
  scope :today, -> { where(:created_at.gte => Date.today.beginning_of_day, :created_at.lte => Date.today.end_of_day) }
  scope :month, -> { where(:created_at.gte => Date.today.beginning_of_month, :created_at.lte => Date.today.end_of_month) }


  def comment_as_seen_by(viewer)
    (viewer == quoter) ? comment : ""
  end

  def vehicles_html
    self.vehicles.map(&:to_html).join("<br>")
  end

  private

  def validate_quote_request_quotable
    return unless quote_request

    unless quote_request.quotable?
      errors.add :base, "quote request has been closed"
    end
  end

  def validate_quotable_by_quoter
    return unless quote_request

    if quoter.subscription_plan == 'free' and quoter.quotes.month.count >= 5
      errors.add :base, "You cannot quote over 5 times per month."
    end
  end

  def validate_dot_number_of_quoter
    return unless quoter

    if quoter.dot_number.blank?
      errors.add :quoter_id, "required DOT number to bid."
    end
  end

  def vehicle_count_quotable
    return unless quote_request
    return if quote_request.vehicle_count == 1

    if vehicle_count > quote_request.vehicle_count
      errors.add :vehicle_count, "cannot be greater than vehicle count of quote_request."
    end
  end

end
