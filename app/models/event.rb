class Event
  include Mongoid::Document
  include Mongoid::Timestamps

  field :description, :type => String
  field :company_id, :type => String  # Source of event

  belongs_to :eventable, :polymorphic => true

  scope :recent, order_by(:updated_at => :desc).limit(100)

  delegate :initiated_by_name, :type, :to => :eventable

  def as_json(options={})
    json_attributes = super(:methods => [:initiated_by_name, :type])
    json_attributes[:eventable] = self.eventable.as_json(:methods => [:type, :formatted_amount, :opportunity_title, :opportunity_bidding_ends, :bids_count, :latest_bid_amount, :lowest_bid_amount] )
    json_attributes
  end
end
