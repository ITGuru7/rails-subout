require 'chargify_api_ares'

Chargify.configure do |c|
  c.subdomain = CHARGIFY_URI
  c.api_key   = CHARGIFY_TOKEN
end
