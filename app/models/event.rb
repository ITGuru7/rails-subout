class Event
  include Mongoid::Document
  include Mongoid::Timestamps

  field :regions, type: Array
  field :eventable_company_id

  belongs_to :actor, :class_name => "Company"
  embeds_one :action, class_name: "EventAction"
  belongs_to :eventable, :polymorphic => true

  before_create :copy_eventable_fields

  def self.recent
    order_by(:updated_at => :desc).includes(:actor).limit(100)
  end

  def self.for(company)
    return self.scoped if company.national_subscriber?

    self.any_of({:regions.in => company.regions}, {:eventable_company_id.in => company.favoriting_buyer_ids})
  end

  private

  def copy_eventable_fields
    self.regions = eventable.regions
    self.eventable_company_id = eventable.buyer_id
  end
end
