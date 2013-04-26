class Company
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Search

  field :name, type: String
  field :email, type: String

  field :fleet_size, type: String
  field :since, type: String
  field :owner, type: String
  field :contact_name, type: String
  field :contact_phone, type: String
  field :tpa, type: String
  field :website
  field :prelaunch, type: Boolean
  field :logo_id
  field :abbreviated_name
  field :dot_number, type: String
  field :insurance, type: String
  field :cell_phone, type: String

  field :favorite_supplier_ids, type: Array, default: []
  field :favoriting_buyer_ids, type: Array, default: []
  field :created_from_invitation_id
  field :created_from_subscription_id

  field :subscription_plan, default: 'free'
  field :regions, type: Array, default: []

  field :notification_type, default: 'Individual'
  field :notification_email

  field :total_sales, type: Integer, default: 0
  field :total_winnings, type: Integer, default: 0
  field :total_won_bids_count, type: Integer, default: 0

  field :last_upgraded_at, type: Time
  field :has_ada_vehicles, type: Boolean, default: false
  field :locked_at, type: Time
  field :vehicles, type: Array, default: []
  field :payments, type: Array, default: []

  #address stuff TODO ask Tom about this
  field :street_address, type: String
  field :zip_code, type: String
  field :city, type: String
  field :state, type: String
  field :active, type: Boolean
  field :company_msg_path, type: String, default: ->{ SecureRandom.uuid }
  field :member, type: Boolean, default: false
  field :auctions_count, type: Integer, default: 0
  field :auctions_expired_count, type: Integer, default: 0
  field :bids_count, type: Integer, default: 0

  scope :recent, -> { desc(:created_at) }

  attr_accessor :password, :password_confirmation
  attr_protected :ratings_taken

  belongs_to :created_from_invitation, class_name: 'FavoriteInvitation', inverse_of: :created_company
  belongs_to :created_from_subscription, class_name: 'GatewaySubscription', inverse_of: :created_company

  has_many :ratings_given, class_name: 'Rating', inverse_of: :rater 
  has_many :ratings_taken, class_name: 'Rating', inverse_of: :ratee

  has_many :users
  has_many :auctions, class_name: "Opportunity", foreign_key: 'buyer_id'
  has_many :bids, foreign_key: 'bidder_id'

  accepts_nested_attributes_for :users

  validates :name, presence: true
  validates :abbreviated_name, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates_confirmation_of :password


  # FIXME: Thomas Total Hack
  # validates_presence_of :created_from_invitation_id, :on => :create, unless: 'created_from_subscription_id.present?'
  validate :validate_invitation, :on => :create, if: "created_from_invitation_id.present?"
  validate :validate_subscription, :on => :create, if: "created_from_subscription_id.present?"
  validate :check_nils

  before_create :set_subscription_info
  after_create :accept_invitation!, if: "created_from_invitation_id.present?"
  after_create :confirm_subscription!, if: "created_from_subscription_id.present?"

  search_in :name, :email

  def check_nils
    errors.add(:favorite_supplier_ids, "is not defined") if favorite_supplier_ids.nil?
    errors.add(:favoriting_buyer_ids, "is not defined") if favoriting_buyer_ids.nil?
  end

  def notifiable_email
    return email if notification_email.blank?
    notification_email
  end

  def self.notified_recipients_by(opportunity)
    options = []
    if opportunity.for_favorites_only?
      options << {:id.in => opportunity.buyer.favorite_supplier_ids}
    else
      options << {:subscription_plan => 'subout-national-service'}
      options << {:subscription_plan => 'subout-partner'}
      options << {:regions.in => opportunity.regions}
    end

    Company.any_of(*options).excludes(id: opportunity.buyer_id, notification_type: 'None')
  end

  def favorite_suppliers
    Company.where(:id.in => self.favorite_supplier_ids)
  end

  def favoriting_buyers
    Company.where(:id.in => self.favoriting_buyer_ids)
  end

  def add_favorite_supplier!(supplier)
    self.favorite_supplier_ids << supplier.id
    self.save

    supplier.favoriting_buyer_ids << Moped::BSON::ObjectId.from_string(self.id)
    supplier.save

    unless DEVELOPMENT_MODE
      Pusher['global'].trigger!('added_to_favorites', company_id: self.id, supplier_id: supplier.id)
    end
  end

  def remove_favorite_supplier!(supplier)
    self.favorite_supplier_ids.delete( supplier.id )
    self.save

    supplier.favoriting_buyer_ids.delete( self.id )
    supplier.save

    unless DEVELOPMENT_MODE
      Pusher['global'].trigger!('removed_from_favorites', company_id: self.id, supplier_id: supplier.id)
    end
  end

  def state_by_state_subscriber?
    subscription_plan == 'state-by-state-service'
  end

  def national_subscriber?
    subscription_plan == 'subout-national-service' ||
    subscription_plan == 'subout-partner'
  end

  def create_initial_user!
    return unless users.empty?
    users.create!(email: email, password: password)
  end

  def inviter
    self.created_from_invitation.buyer
  end

  def subscribed?(regions)
    return true if self.national_subscriber?
    if (regions & self.regions).empty?
      return false
    else
      return true
    end
  end

  def self.companies_for(company)
    company.abbreviated_name = "Self"
    [company] + Company.ne(id: company.id).to_a
  end

  def set_subscription_info
    if subscription = created_from_subscription
      self.subscription_plan = subscription.product_handle
      self.regions = subscription.regions
    else
      self.subscription_plan = "free"
      self.regions = []
    end
  end

  def last_sign_in_at
    first_user.try(:last_sign_in_at)
  end

  def first_user
    @first_user ||= self.users.to_a.first
  end

  def auth_token_hash
    if first_user.present?
      first_user.auth_token_hash
    else
      {}
    end
  end

  def is_a_favorite_of?(other_company) 
    self.favoriting_buyer_ids.include?(other_company.id)
  end

  def available_opportunities(sort_by = :bidding_ends_at, sort_direction = 'asc', start_date = nil, vehicle_type=nil, trip_type=nil, query=nil)
    sort_by ||= :bidding_ends_at
    sort_direction ||= "asc"
    start_date = nil if start_date == "null" or start_date.blank?
    vehicle_type = nil if vehicle_type == "null" or vehicle_type.blank?
    trip_type = nil if trip_type == "null" or trip_type.blank?

    options = []
    options << {:buyer_id.in => self.favoriting_buyer_ids}

    if self.regions.present?
      options << {:for_favorites_only => false, :start_region.in => self.regions}
      options << {:for_favorites_only => false, :end_region.in => self.regions}
    end
    conditions = {
      canceled: false,
      :bidding_ends_at.gt => Time.now,
      winning_bid_id: nil,
      :buyer_id.ne => self.id
    }
    conditions[:start_date] = start_date if start_date
    conditions[:vehicle_type] = vehicle_type if vehicle_type
    conditions[:trip_type] = trip_type if trip_type
    opportunities = Opportunity.any_of(*options).where(conditions)
    opportunities = opportunities.search(query) if query.present?
    opportunities.order_by(sort_by => sort_direction)
  end

  def sales_info_messages
    sales_messages = []
    sales_messages << "#{ActionController::Base.helpers.number_to_currency(total_sales, precision: 0)} in sales" if total_sales > 0
    sales_messages << "#{ActionController::Base.helpers.number_to_currency(total_winnings, precision: 0)} in winnings" if total_winnings > 0
    sales_messages << "Bid on #{opportunities_bid_on.size} opportunities worth #{ActionController::Base.helpers.number_to_currency(opportunities_bid_on.sum(&:value), precision: 0)}" if bids.count > 0

    sales_messages << "No activity so far" if sales_messages.empty?

    sales_messages
  end

  def opportunities_bid_on
    Opportunity.where(:id.in => self.bids.distinct(:opportunity_id))
  end

  def sign_up_errors
    sign_up_errors = self.errors.to_hash
    if user = self.users.first and !user.valid?
      sign_up_errors.delete(:users)
      sign_up_errors.merge!(user.errors.to_hash)
    end
    sign_up_errors
  end

  def self.sort(sort_by, direction)
    scoped.order_by(sort_by => direction)
  end

  def update_regions!(regions)
    regions ||= []
    upgrading = (regions - self.regions).present? 
    self.last_upgraded_at = Time.now if upgrading

    self.created_from_subscription.update_regions!(regions)
    self.regions = regions
    self.save
  end

  def update_product!(product)
    products = ["free", "state-by-state-service", "subout-national-service"]

    upgrading = products.index(product) > products.index(self.subscription_plan) 
    self.last_upgraded_at = Time.now if upgrading 

    self.created_from_subscription.update_product!(product)
    set_subscription_info
    self.save
  end

  def self.csv_column_names
    [
      "_id","email", "name", "owner", "contact_name", "contact_phone", "created_at",
      "last_sign_in_at", "subscription_plan", "regions", "auctions_count", "bids_count"
    ]
  end

  def csv_value_for(column)
    if column == "regions"
      national_subscriber? ? "all" : regions
    else
      send(column)
    end
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << csv_column_names
      all.each do |item|
        csv << csv_column_names.map { |column| item.csv_value_for(column) }
      end
    end
  end

  def upgraded_recently
    last_upgraded_at = self.last_upgraded_at || self.created_at
    last_upgraded_at > 1.month.ago
  end

  def access_locked?
    self.locked_at.present?
  end

  def lock_access!
    users.each(&:lock_access!)
    self.update_attribute(:locked_at, Time.now)
  end

  def unlock_access!
    users.each(&:unlock_access!)
    self.update_attribute(:locked_at, nil)
  end
  
  def change_emails!(email)
    self.update_attribute(:email, email)
    self.created_from_subscription.update_attribute(:email, email)
    self.users.first.update_attribute(:email, email)
  end

  private

  def validate_invitation
    return if self.created_from_invitation && self.created_from_invitation.pending?

    errors.add(:created_from_invitation_id, "Invalid invitation")
  end

  def validate_subscription
    return if self.created_from_subscription && self.created_from_subscription.pending?

    errors.add(:created_from_subscription_id, "Invalid subscription")
  end


  def accept_invitation!
    self.created_from_invitation.accept!
  end

  def confirm_subscription!
    self.created_from_subscription.confirm!
  end
end
