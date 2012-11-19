class BidSerializer < ActiveModel::Serializer
  include ActionView::Helpers::NumberHelper

  attributes :_id, :amount, :formatted_amount, :created_at

  has_one :opportunity, serializer: OpportunityShortSerializer

  def formatted_amount
    number_to_currency(bid.amount, :unit=>'')
  end
end
