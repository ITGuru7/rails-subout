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
  field :state

  has_one :created_company, class_name: "Company", inverse_of: :created_from_subscription

  attr_accessible :regions, :product_handle, :subscription_id, :customer_id, :email, :first_name, :last_name, :organization, :state

  before_create :set_regions
  after_save :update_chargify_email, if: "self.email_changed?"

  scope :pending, -> { where(confirmed: false) }
  scope :recent, -> { desc(:created_at) }

  validates :subscription_id, uniqueness: true

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
        self.regions = self.class.region_names
      end
    else
      self.regions = self.class.region_names
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

  def self.by_category(category)
    if category == "registered"
      scoped.where(confirmed: true)
    elsif category == "not_registered"
      scoped.where(confirmed: false)
    else
      scoped
    end
  end

  def name
    "#{self.first_name} #{self.last_name}"
  end

  def created_company_name
    self.created_company.try(:name)
  end

  def subscription_url
    subscription_id.blank? ? "" : "https://subout.chargify.com/subscriptions/#{subscription_id}"
  end

  def customer_url
    customer_id.blank? ? "" : "https://subout.chargify.com/customers/#{customer_id}"
  end

  def self.csv_column_names
    ["_id","email", "name", "organization", "subscription_url", "customer_url", "product_handle", "regions", "confirmed", "created_company_name"]
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << csv_column_names
      all.each do |item|
        csv << csv_column_names.map { |column| item.send(column) }
      end
    end
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
    self.update_attributes(regions: regions)
  end

  def update_product!(product_handle)
    sub = Chargify::Subscription.find(self.subscription_id)
    sub.product_handle = product_handle
    sub.save

    self.product_handle = product_handle
    set_regions
    self.save
  end

  def update_product_and_regions!(options)
    update_product!(options[:product_handle]) if product_handle != options[:product_handle]
    if product_handle == "state-by-state-service"
      new_regions = options[:regions] || []
      update_regions!(new_regions)
    end
  end

  def exists_on_chargify?
    Chargify::Subscription.exists?(self.subscription_id)
  end

  def update_chargify_email
    customer = Chargify::Customer.find(self.customer_id)
    customer.email = self.email
    customer.save
  end
end
