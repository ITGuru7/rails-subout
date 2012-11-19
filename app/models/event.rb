class Event
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :actor, :class_name => "Company"
  embeds_one :action, class_name: "EventAction"
  belongs_to :eventable, :polymorphic => true

  def self.recent
    order_by(:updated_at => :desc).includes(:actor).limit(100)
  end
end
