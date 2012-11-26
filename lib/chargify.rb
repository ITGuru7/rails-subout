require 'rubygems'
require 'httparty'

class Chargify
  include HTTParty
  base_uri 'subout.chargify.com'
  basic_auth 'FsikQqr_iR0tcokkv8db', 'x'

  def self.get_subscription(subscription_id)
    self.class.get("/subscriptions/#{subscription_id}.json")
  end

  def self.get_components(subscription_id)
    self.class.get("/subscriptions/#{subscription_id}/components.json")
  end
end

#chargify = Chargify.new
#sub = chargify.get_subscription(2559906)

#PP.pp(sub["subscription"], $>, 40)

#component = chargify.get_components(2559906)

#PP.pp(component, $>, 40)
