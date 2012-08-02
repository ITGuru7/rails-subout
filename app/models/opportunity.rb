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
end
