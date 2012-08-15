class Event
  include Mongoid::Document

  field :description, :type => String
  field :model_id, :type => Integer
  field :model_type, :type => String
  field :company_id, :type => String  # Source of event

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

end
