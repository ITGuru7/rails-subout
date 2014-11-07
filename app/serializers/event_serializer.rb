class EventSerializer < ActiveModel::Serializer
  attributes :_id, :created_at, :regions, :eventable_company_id, :actor

  #for the speeding
  #has_one :actor, serializer: ActorShortSerializer
  has_one :action
  has_one :eventable, serializer: OpportunityShortSerializer

  def actor
    {:_id => object.actor_id}
  end
end
