class BidShortSerializer < ActiveModel::Serializer
  include ActionView::Helpers::NumberHelper

  attributes :_id, :amount, :formatted_amount, :created_at, :comment

  has_one :bidder, serializer: ActorSerializer

  def formatted_amount
    number_to_currency(bid_short.amount, :unit=>'')
  end

  def comment
    bid_short.comment_as_seen_by(bid_short.opportunity.viewer)
  end
end
