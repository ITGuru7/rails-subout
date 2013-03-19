class OpportunityShortSerializer < ActiveModel::Serializer
  attributes :_id, :created_at, :name, :icon, :type, :for_favorites_only,
    :quick_winnable, :bidable?, :buyer_id, :start_region, :end_region,
    :buyer_name, :buyer_abbreviated_name, :reference_number, :canceled, :win_it_now_price, :status,
    :bidding_ends_at, :description, :highest_bid_amount, :lowest_bid_amount, :ada_required, :start_date, :reserve_amount, :forward_auction

  def icon
    "icon-#{object.type.parameterize}"
  end

  def buyer_name
    object.buyer.name
  end

  def buyer_abbreviated_name
    object.buyer.abbreviated_name
  end
end
