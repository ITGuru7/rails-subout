require 'my_chargify'

class GatewaySubscription
  include Mongoid::Document
  include Mongoid::Timestamps

  REGION_NAMES = ['Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'District of Columbia', 'Florida', 'Georgia', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York' , 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', '
    Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas' , 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming']

  field :email
  field :first_name
  field :last_name
  field :organization
  field :subscription_id
  field :customer_id
  field :product_handle
  field :vehicle_count, type: Integer, default: 0
  field :confirmed, type: Boolean, default: false
  field :state
  field :payment_state

  has_one :created_company, class_name: "Company", inverse_of: :created_from_subscription

  attr_accessible :product_handle, :subscription_id, :customer_id, :email, :first_name, :last_name, :organization, :state

  after_save :update_chargify_email, if: "self.email_changed?"

  scope :pending, -> { where(confirmed: false) }
  scope :recent, -> { desc(:created_at) }

  validates :subscription_id, uniqueness: true

  def self.revenues(options)
    result = Hash.new

    start_date = Date.parse(options[:start_date])
    end_date = Date.parse(options[:end_date])

    GatewaySubscription::REGION_NAMES.each do |region|
      tmp_value = Hash.new
      tmp_value[:posted_oppor_count] = Opportunity.by_region(region).by_period(start_date, end_date).count
      tmp_value[:total_awarded_count] = Opportunity.by_region(region).by_period(start_date, end_date).won.count
      tmp_value[:total_awarded_amount] = Opportunity.by_region(region).by_period(start_date, end_date).won.sum(&:value)
      result[region] = tmp_value
    end

    if options[:sort_order] == 'asc'
      result.sort_by{ |key, value| value[options[:sort_by].to_sym] }
    else
      result.sort_by{ |key, value| value[options[:sort_by].to_sym] }.reverse
    end
  end

  def confirm!
    update_attribute(:confirmed, true)
  end

  def pending?
    !confirmed
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
    subscription_id.blank? ? "" : "https://#{CHARGIFY_URI}/subscriptions/#{subscription_id}"
  end

  def customer_url
    customer_id.blank? ? "" : "https://#{CHARGIFY_URI}/customers/#{customer_id}"
  end

  def self.csv_column_names
    ["_id","email", "name", "organization", "subscription_url", "customer_url", "product_handle", "confirmed", "created_company_name"]
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << csv_column_names
      all.each do |item|
        csv << csv_column_names.map { |column| item.send(column) }
      end
    end
  end

  def update_vehicle_count!(vehicle_count)
    return if self.product_handle != 'subout-pro-service' 

    sub = Chargify::Subscription.find(self.subscription_id)
    bus_component = sub.components.first
    bus_component.allocated_quantity = vehicle_count > 2 ? vehicle_count - 2 : 0
    bus_component.save

    self.vehicle_count = vehicle_count
    self.save
  end

  def update_product!(product_handle)
    sub = Chargify::Subscription.find(self.subscription_id)
    sub.product_handle = product_handle
    sub.save

    self.product_handle = product_handle
    self.save
  end

  def update_product_and_vehicle_count!(options)
    update_product!(options[:product_handle])
    if product_handle == "subout-pro-service" and options[:vehicle_count] 
      update_vehicle_count!(options[:vehicle_count])
    end
  end

  def exists_on_chargify?
    Chargify::Subscription.exists?(self.subscription_id)
  end

  def chargify_subscription
    Chargify::Subscription.find(self.subscription_id)
  end

  def update_chargify_email
    customer = Chargify::Customer.find(self.customer_id)
    customer.email = self.email
    customer.save
  end

  def has_valid_credit_card?
    cs = chargify_subscription
    return false unless cs.present?
    cc = cs.credit_card
    return false unless cc.present?
    Time.new(cc.expiration_year, cc.expiration_month) > Time.now.beginning_of_month
  end
end
