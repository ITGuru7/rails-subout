class EventObserver < Mongoid::Observer
  observe :event

  def after_create(event)
    send_msg('event_updated', event)
  end
  
  def send_msg(pubnub_path, associated_object)
    # We need to publish this event on the global event list.
    pn = Pubnub.new(:publish_key => Rails.configuration.pubnub_publish_key, # publish_key only required if publishing.
        :subscribe_key => Rails.configuration.pubnub_subscribe_key,         # required
        :ssl => false)
    @mycallback = lambda{|message| puts(message)}    
    pn.publish({
      'channel' => pubnub_path,
      'message' => associated_object.to_json,
      'callback' => @mycallback
    })
    end
end
