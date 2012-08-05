class Opportunity
  include Mongoid::Document
  field :company_id, type: Integer
  field :name, type: String
  field :description, type: String
  field :starting_location_id, type: Integer
  field :ending_location_id, type: Integer
  field :start_date, type: Time
  field :end_date, type: Time
  field :opportunity_type_id, type: Integer
  field :bidding_ends, type: Time
  field :bidding_done, type: Boolean
  field :buy_it_now, type: Boolean
  field :buy_it_now_price, type: BigDecimal 
  field :winning_bid_id, type: Integer

  belongs_to :company, :class_name => "Company", :foreign_key => "company_id"
  has_one :opportunity_type, :class_name => "OpportunityType", :foreign_key => "opportunity_type_id"
  has_one :winning_bid, :class_name => "Bid", :foreign_key => "winning_bid_id"
  has_one :starting_location, :class_name => "Location", :foreign_key => "starting_location_id"
  has_one :ending_location, :class_name => "Location", :foreign_key => "ending_location_id"
en