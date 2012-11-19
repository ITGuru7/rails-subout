class EventSerializer < ActiveModel::Serializer
  attributes :_id, :created_at

  has_one :actor, serializer: ActorSerializer
  has_one :action
  has_one :eventable, serializer: OpportunityShortSerializer
end
