class Event
  include Mongoid::Document
  include Mongoid::Timestamps

  # To filter events by regions
  field :regions, type: Array

  belongs_to :actor, :class_name => "Company"
  embeds_one :action, class_name: "EventAction"
  belongs_to :eventable, :polymorphic => true

  before_create :set_regions

  def self.recent
    order_by(:updated_at => :desc).includes(:actor).limit(100)
  end

  def self.for(company)
    company.state_by_state_subscriber? ? self.in(regions: company.regions) : self.scoped
  end

  private

  def set_regions
    self.regions = eventable.regions
  end
end
