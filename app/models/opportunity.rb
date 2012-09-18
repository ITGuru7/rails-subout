class Opportunity
  include Mongoid::Document
  field :company_id, type: Integer
  field :name, type: String
  field :description, type: String
  field :starting_location, type: String
  field :ending_location, type: String
  field :start_date, type: Time
  field :end_date, type: Time
  field :opportunity_type_id, type: Integer
  field :bidding_ends, type: Time
  field :bidding_done, type: Boolean, default: false
  field :quick_winnable, type: Boolean, default: false
  field :win_it_now_price, type: BigDecimal 
  field :winning_bid_id, type: Integer
  field :for_favorites_only, type: Boolean, default: false


  belongs_to :company, :class_name => "Company"
  has_one :opportunity_type, :class_name => "OpportunityType", :foreign_key => "opportunity_type_id"
  has_one :starting_location, :class_name => "Location", :foreign_key => "starting_location_id"
  has_one :ending_location, :class_name => "Location", :foreign_key => "ending_location_id"
  has_many :bids

  validates_presence_of :company_id
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :start_date, :on => :create, :message => "can't be blank"
  validates_presence_of :end_date, :on => :create, :message => "can't be blank"
  validates_presence_of :bidding_ends, :on => :create, :message => "can't be blank"

end

