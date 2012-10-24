class Event
  include Mongoid::Document
  include Mongoid::Timestamps

  field :description, :type => String
  field :company_id, :type => String  # Source of event

  belongs_to :eventable, :polymorphic => true

  scope :recent, order_by(:updated_at => :desc).limit(100)

  delegate :initiated_by_name, :type, :to => :eventable

  def send_msg(pubnub_path, associated_object)
    Rails.logger.info("Sending the message now!!!!")
  	pubnub = Pubnub.new(
    	Rails.configuration.pubnub_publish_key,
    	Rails.configuration.pubnub_subscribe_key,
    	Rails.configuration.pubnub_secret_key,
    	"", false)

  	# We need to publish this event on the global event list.

  	pubnub.publish({
    'channel' => pubnub_path,
    'message' => [self, associated_object].to_json,
    'callback' => lambda do |message|
       puts(message)
     end })
  end

  def as_json(options={})
    json_attributes = super(:methods => [:initiated_by_name, :type])
    json_attributes[:eventable] = self.eventable.as_json(:methods => [:formatted_amount, :opportunity_title, :opportunity_bidding_ends, :bids_count, :latest_bid_amount, :lowest_bid_amount] )
    json_attributes
  end
end
