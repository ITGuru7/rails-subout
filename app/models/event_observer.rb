class EventObserver < Mongoid::Observer
  observe :event

  def after_create(event)
    send_msg('event_updated', event)
  end
  
  def send_msg(pubnub_path, associated_object)
    pn = Pubnub.new(:publish_key => Rails.configuration.pubnub_publish_key,
                    :subscribe_key => Rails.configuration.pubnub_subscribe_key,
                    :ssl => false)

    pn.publish({
      'channel' => pubnub_path,
      'message' => associated_object.as_json,
      'callback' => lambda{|message| puts(message)} 
    })
  end
end
