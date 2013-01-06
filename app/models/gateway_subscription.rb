require 'chargify'

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

  attr_accessible :regions, :product_handle

  has_one :created_company, :class_name => "Company"

  before_create :set_regions, :if => "state_by_state_service?"

  scope :pending, where(confirmed: false)

  def set_regions
    unless ENV['DEV_SITE']
      response = Chargify.get_components(subscription_id)
      self.regions = response.map{|c| c["component"]["name"] if c["component"]["enabled"]}.compact
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
