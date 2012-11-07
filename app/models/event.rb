class Event
  include Mongoid::Document
  include Mongoid::Timestamps

  field :description
  field :verb

  belongs_to :company # Source of event
  belongs_to :eventable, :polymorphic => true

  scope :recent, order_by(:updated_at => :desc).limit(100)

  delegate :initiated_by_name, :type, :to => :eventable

  def as_json(options={})
    json_attributes = super(:methods => [:initiated_by_name, :type])

    json_attributes[:eventable] = self.eventable.as_json(:methods => [:type, :formatted_amount, :opportunity_title, :opportunity_bidding_ends, :bids_count, :latest_bid_amount, :lowest_bid_amount, :icon_url] )
    json_attributes[:actor] = self.company.as_json
    json_attributes
  end

  #e.g.
  #"opportunity_created"
  #"opportunity_bidding_won"
  #"opportunity_cancelled"
  def type
    if verb.present?
      "#{eventable_type}_#{verb}".downcase
    else
      eventable_type 
    end
  end

end
