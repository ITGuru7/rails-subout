class Company
  include Mongoid::Document
  include Mongoid::Timestamps

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
  field :cell_phone, type: String

  field :favorite_supplier_ids, type: Array, default: []
  field :favoriting_buyer_ids, type: Array, default: []
  field :created_from_invitation_id
  field :created_from_subscription_id

  field :subscription_plan, default: 'free'
  field :regions, type: Array, default: []

  field :notification_type, default: 'Individual'

  field :total_sales, type: Integer, default: 0
  field :total_winnings, type: Integer, default: 0

  #address stuff TODO ask Tom about this
  field :street_address, type: String
  field :zip_code, type: String
  field :city, type: String
  field :state, type: String
  field :active, type: Boolean
  field :company_msg_path, type: String, default: ->{ SecureRandom.uuid }
  field :member, type: Boolean, default: false

  scope :recent, -> { desc(:created_at) }

  attr_accessor :password, :password_confirmation

  belongs_to :created_from_invitation, class_name: 'FavoriteInvitation', inverse_of: :created_company
  belongs_to :created_from_subscription, class_name: 'GatewaySubscription', inverse_of: :created_company

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

  before_create :set_subscription_info, if: "created_from_subscription_id.present?"
  after_create :accept_invitation!, if: "created_from_invitation_id.present?"
  after_create :confirm_subscription!, if: "created_from_subscription_id.present?"

  def check_nils
    errors.add(:favorite_supplier_ids, "is not defined") if favorite_supplier_ids.nil?
    errors.add(:favoriting_buyer_ids, "is not defined") if favoriting_buyer_ids.nil?
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

    supplier.favoriting_buyer_ids << self.id
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
    self.subscription_plan = created_from_subscription.product_handle
    self.regions = created_from_subscription.regions
  end

  def last_sign_in_at
    first_user.try(:last_sign_in_at)
  end

  def first_user
    self.users.first
  end

  def auth_token_hash
    if first_user.present?
      first_user.auth_token_hash
    else
      {}
    end
  end

  def available_opportunities(sort_by = :bidding_ends_at, sort_direction = 'asc')
    sort_by ||= :bidding_ends_at
    sort_direction ||= "asc"

    options = []
    options << {:for_favorites_only => true, :buyer_id.in => self.favoriting_buyer_ids}
    options << {:for_favorites_only => false, :start_region.in => self.regions}
    options << {:for_favorites_only => false, :end_region.in => self.regions}
    Opportunity.any_of(*options).where(canceled: false, :bidding_ends_at.gt => Time.now, winning_bid_id: nil, :buyer_id.ne => self.id).order_by(sort_by => sort_direction)
  end

  def sales_info_messages
    sales_messages = []
    sales_messages << "$#{total_sales} in sales" if total_sales > 0
    sales_messages << "$#{total_winnings} in winnings" if total_winnings > 0
    sales_messages << "Bid on #{opportunities_bid_on.size} opportunities worth $#{opportunities_bid_on.sum(&:value)}" if bids.count > 0

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
    dir = (direction == "asc") ? 1 : -1

    case sort_by
    when "auctions_count"
      scoped.sort_by { |c| c.auctions.count * dir }
    when "bids_count"
      scoped.sort_by { |c| c.bids.count * dir }
    else
      scoped.order_by(sort_by => direction)
    end
  end

  def update_regions!(regions)
    if regions.nil?
      errors.add(:base, "Regions cannot be nil")
      return false
    end

    self.created_from_subscription.update_regions!(regions)
    self.update_attributes(regions: regions)
  end

  def update_product!(product)
    self.created_from_subscription.update_product!(product)
    set_subscription_info
    self.save
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
