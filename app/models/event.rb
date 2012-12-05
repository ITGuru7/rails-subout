class Event
  include Mongoid::Document
  include Mongoid::Timestamps

  field :region

  belongs_to :actor, :class_name => "Company"
  embeds_one :action, class_name: "EventAction"
  belongs_to :eventable, :polymorphic => true

  before_create :set_region

  def self.recent
    order_by(:updated_at => :desc).includes(:actor).limit(100)
  end

  def self.for(company)
    # FIXME: Add events from favorite companies
    company.regions == "all" ? self.scoped : self.in(region: company.regions)
  end

  private

  def set_region
    self.region = eventable.region
  end
end
