require 'rubygems'
require 'httparty'

class MyChargify
  include HTTParty
  base_uri CHARGIFY_URI
  basic_auth CHARGIFY_TOKEN, 'x'

  def self.get_subscription(subscription_id)
    self.get("/subscriptions/#{subscription_id}.json")
  end

  def self.get_components(subscription_id)
    self.get("/subscriptions/#{subscription_id}/components.json")
  end
end

#chargify = MyChargify.new
#sub = chargify.get_subscription(2559906)

#PP.pp(sub["subscription"], $>, 40)

#component = chargify.get_components(2559906)

#PP.pp(component, $>, 40)
