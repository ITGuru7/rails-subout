class OpportunityShortSerializer < ActiveModel::Serializer
  attributes :_id, :created_at, :name, :icon, :type, :for_favorites_only,
    :quick_winnable, :bidable?, :buyer_id, :start_region, :end_region

  def icon
    "icon-#{opportunity_short.type.parameterize}"
  end
end
