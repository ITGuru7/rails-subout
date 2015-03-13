class OnetimeToken
  #onetime token for vendors
  include Mongoid::Document
  include Mongoid::Timestamps
  embedded_in :vendor, inverse_of: :onetime_tokens

  field :token, type: String
  validates_presence_of :token
end
