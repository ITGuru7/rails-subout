class Offer
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Token

  STATES = %w(active canceled declined accepted expired)

  token field_name: :reference_number, retry_count: 7, length: 7, contains: :upper_alphanumeric

  field :amount, type: Money
  field :vehicle_type, type: String
  field :state, type: String, default: "active"
  field :token, type: String

  paginates_per 30

  belongs_to :opportunity, :inverse_of => :offer
  belongs_to :vendor, :inverse_of=>:offers

  index vendor_id: 1
  index opportunity_id: 1
  index reference_number: 1

  validates_presence_of :opportunity_id, on: :create, message: "can't be blank"
  validates_presence_of :amount, on: :create, message: "can't be blank"
  validates :amount, numericality: { greater_than: 0 }

  scope :active, -> { where(:state.ne => 'canceled') }
  scope :recent, -> { desc(:created_at) }
  scope :accepted, -> { where(:state => 'accepted') }

  before_create :set_onetime_token
  after_create :notify_vendor

  STATES.each do |value|
    define_method :"is_#{value}?" do 
      self.state == value
    end
  end

  def set_onetime_token
    self.token = SecureRandom.base64(32)
  end

  def set_onetime_token!
    self.token = SecureRandom.base64(32)
    self.save
  end

  def accept!
    self.state = 'accepted'
    self.save
    self.set_onetime_token!
    Notifier.delay.accepted_offer_to_buyer(self.id)
    Notifier.delay.accepted_offer_confirmation_to_vendor(self.id)
  end

  def cancel!
    self.state = 'canceled'
    self.save
  end

  def decline!
    self.state = 'declined'
    self.save
    self.set_onetime_token!
    Notifier.delay.declined_offer_to_buyer(self.id)
  end

  private
  def notify_vendor
    Notifier.delay.offered_auction_to_vendor(self.id)
  end

end
