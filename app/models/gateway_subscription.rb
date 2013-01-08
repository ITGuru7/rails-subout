require 'chargify'

STATE_NAMES = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado",
"Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas",
"Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi",
"Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York",
"North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island",
"South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington",
"West Virginia", "Wisconsin", "Wyoming", "District of Columbia", "Puerto Rico"]

class GatewaySubscription
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email
  field :first_name
  field :last_name
  field :organization
  field :subscription_id
  field :customer_id
  field :product_handle
  field :confirmed, type: Boolean, default: false
  field :regions, type: Array, default: []

  attr_accessible :regions, :product_handle, :subscription_id, :customer_id, :email, :first_name, :last_name, :organization

  has_one :created_company, :class_name => "Company"

  before_create :set_regions, :if => "state_by_state_service?"

  scope :pending, where(confirmed: false)

  def set_regions
    unless ENV['DEV_SITE']
      if state_by_state_service? 
        response = Chargify.get_components(subscription_id)
        self.regions = response.map{|c| c["component"]["name"] if c["component"]["enabled"]}.compact unless response.nil?
      else
        self.regions = STATE_NAMES
      end
    end
  end

  def confirm!
    update_attribute(:confirmed, true)
  end

  def pending?
    !confirmed
  end

  def state_by_state_service?
    product_handle == 'state-by-state-service'
  end
end
