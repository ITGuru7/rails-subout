require 'my_chargify'

class GatewaySubscription
  include Mongoid::Document
  include Mongoid::Timestamps

  REGIONS = Chargify::Component.find(
    :all, 
    :params => {
      :product_family_id => Chargify::ProductFamily.find_by_handle("subout").id
    }
  )

  field :email
  field :first_name
  field :last_name
  field :organization
  field :subscription_id
  field :customer_id
  field :product_handle
  field :confirmed, type: Boolean, default: false
  field :regions, type: Array, default: []

  has_one :created_company, class_name: "Company", inverse_of: :created_from_subscription

  attr_accessible :regions, :product_handle, :subscription_id, :customer_id, :email, :first_name, :last_name, :organization

  before_create :set_regions

  scope :pending, -> { where(confirmed: false) }
  scope :recent, -> { desc(:created_at) }

  def self.region_prices
    return @region_prices if @region_prices

    #@region_prices = {}
    #REGIONS.each do |region|
      #@region_prices[region.name] = region.unit_price.to_i
    #end

    #@region_prices

    @region_prices = REGIONS.map do |region|
      {
        name: region.name,
        price: region.unit_price.to_i
      }
    end
  end

  def self.region_names
    REGIONS.map {|s| s.name }
  end

  def set_regions
    unless DEVELOPMENT_MODE
      if state_by_state_service?
        response = MyChargify.get_components(subscription_id)
        self.regions = response.map{|c| c["component"]["name"] if c["component"]["enabled"]}.compact unless response.nil?
      else
        self.regions = region_names
      end
    else
      self.regions = region_names
      self.product_handle = 'state-by-state-service'
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

  def company_last_sign_in_at
    self.created_company.try(:last_sign_in_at)
  end

  def update_regions!(regions)
    sub = Chargify::Subscription.find(self.subscription_id)
    sub.components.each do |component|
      was_enabled = component.enabled
      if regions.include?(component.name) 
        component.enabled = true
      else
        component.enabled = false
      end
      component.save unless component.enabled == was_enabled
    end
    self.update_attributes(:regions => regions)
  end
end
