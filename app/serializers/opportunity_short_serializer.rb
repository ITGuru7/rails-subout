class OpportunityShortSerializer < ActiveModel::Serializer
  attributes :_id, :created_at, :name, :icon, :type, :for_favorites_only,
    :quick_winnable, :bidable?, :buyer_id, :start_region, :end_region,
    :buyer_name, :buyer_abbreviated_name, :reference_number, :canceled, :win_it_now_price

  def icon
    "icon-#{opportunity_short.type.parameterize}"
  end

  def buyer_name
    opportunity_short.buyer.name
  end

  def buyer_abbreviated_name
    opportunity_short.buyer.abbreviated_name
  end
end
