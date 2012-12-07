class Event
  include Mongoid::Document
  include Mongoid::Timestamps

  field :regions, type: Array
  field :eventable_company_id
  field :eventable_for_favorites_only

  belongs_to :actor, :class_name => "Company"
  embeds_one :action, class_name: "EventAction"
  belongs_to :eventable, :polymorphic => true

  before_create :copy_eventable_fields

  def self.recent
    order_by(:updated_at => :desc).includes(:actor).limit(100)
  end

  def self.for(company)
    options = [
      {:eventable_company_id.in => company.favoriting_buyer_ids + [company.id]},
      {:eventable_for_favorites_only => false}
    ]

    if company.state_by_state_subscriber?
      options.last[:regions.in] = company.regions
    end

    self.any_of(*options)
  end

  private

  def copy_eventable_fields
    self.regions = eventable.regions
    self.eventable_for_favorites_only = eventable.for_favorites_only
    self.eventable_company_id = eventable.buyer_id
  end
end
