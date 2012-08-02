class Bid
  include Mongoid::Document
  field :posting_company_id, type: Integer
  field :bidding_company_id, type: Integer
  field :amount, type: BigDecimal
  field :active, type: Boolean
end
