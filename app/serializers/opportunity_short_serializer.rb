class OpportunityShortSerializer < ActiveModel::Serializer
  attributes :_id, :created_at, :name, :icon, :type, 
    :quick_winnable, :bidable?, :buyer_id

  def icon
    "icon-#{opportunity_short.type.parameterize}"
  end
end
