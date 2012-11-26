class Company
  include Mongoid::Document
  field :name, type: String
  field :email, type: String

  #address stuff TODO ask Tom about this
  field :street_address, type: String
  field :zip_code, type: String
  field :city, type: String
  field :state, type: String

  field :region, type: String
  field :fleet_size, type: String
  field :since, type: String
  field :owner, type: String
  field :contact_name, type: String
  field :tpa, type: String

  field :hq_location_id, type: String

  #TODO remove this once we figure out where it's being used
  field :active, type: Boolean

  field :company_msg_path, type: String, default: ->{ SecureRandom.uuid }
  field :member, type: Boolean, default: false

  field :favorite_supplier_ids, type: Array, default: []
  field :favoriting_buyer_ids, type: Array, default: []  #TODO see if come up with a better name

  field :created_from_invitation_id

  field :subscription_plan, default: 'free'
  field :regions, type: Array

  attr_accessor :password, :password_confirmation, :gateway_subscription_id

  belongs_to :created_from_invitation, :class_name => 'FavoriteInvitation', :inverse_of => :created_company
  belongs_to :created_from_subscription, :class_name => 'GatewaySubscription', :inverse_of => :created_company

  has_many :users
  has_many :auctions, class_name: "Opportunity", foreign_key: 'buyer_id'
  has_many :opportunities

  has_many :contacts
  has_many :locations
  has_many :bids, foreign_key: 'bidder_id'

  accepts_nested_attributes_for :users

  validates_presence_of :name, :on => :create
  validates_uniqueness_of :email
  validates_confirmation_of :password

  validates_presence_of :created_from_invitation_id, :on => :create, unless: 'created_from_subscription_id.present?'
  validate :validate_invitation, :on => :create, if: "created_from_invitation_id.present?"
  validate :validate_subscription, :on => :create, if: "created_from_subscription_id.present?"

  before_create :set_subscription_info, if: "created_from_subscription_id.present?"
  after_create :accept_invitation!, if: "created_from_invitation_id.present?"
  after_create :confirm_subscription!, if: "created_from_subscription_id.present?"

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
  end

  def remove_favorite_supplier!(supplier)
    self.favorite_supplier_ids.delete( supplier.id )
    self.save

    supplier.favoriting_buyer_ids.delete( self.id )
    supplier.save
  end

  def guest? 
    subscription_plan == 'free'
  end

  def state_by_state_subscriber? 
    subscription_plan == 'state-by-state-service'
  end

  def create_initial_user!
    return unless users.empty?
    users.create!(email: email, password: password)
  end

  def inviter
    self.created_from_invitation.buyer
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

  def set_subscription_info
    self.regions = created_from_subscription.regions
    self.subscription_plan = created_from_subscription.product_handle
  end

  def accept_invitation!
    self.created_from_invitation.accept! 
  end

  def confirm_subscription!
    self.created_from_subscription.confirm! 
  end
end

