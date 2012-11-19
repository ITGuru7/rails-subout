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

  belongs_to :created_from_invitation, :class_name => 'FavoriteInvitation', :inverse_of => :created_company

  attr_accessor :password, :password_confirmation

  has_many :users
  has_many :auctions, class_name: "Opportunity", foreign_key: 'buyer_id'
  has_many :opportunities

  has_many :contacts
  has_many :locations
  has_many :bids, foreign_key: 'bidder_id'

  accepts_nested_attributes_for :users

  validates_presence_of :name, :on => :create
  validates_presence_of :created_from_invitation_id, :on => :create
  validates_uniqueness_of :email
  validates_confirmation_of :password

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

  def needs
    self.opportunities
  end

  def interested_in_event?(event)
  	true
  end

  def guest? 
    !member?
  end

  def send_event(event, associated_object)
    #Rails.logger.info "Queing event to be sent to path #{company_msg_path}"
    #event.delay.send_msg(company_msg_path, associated_object)
  end

  def create_initial_user!
    return unless users.empty?
    users.create!(email: email, password: password)
  end

  #def logo
    #"img/company/#{self.id}.png"
  #end

  #def as_json(options={})
    #options[:methods] = :logo
    #super
  #end

  def inviter
    self.created_from_invitation.buyer
  end
end
