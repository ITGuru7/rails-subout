class Vendor
  include Mongoid::Document

  field :email,       :type => String
  field :address,     :type => String
  field :crm_id,      :type => String

  embeds_many :onetime_tokens

  validates_presence_of :email
  validates_uniqueness_of :email

  before_save do
    self.email.downcase! if self.email
  end

  def self.find_by_email(email)
    where(:email => email).first
  end

  def create_onetime_token_for(opportunity)
    self.onetime_tokens.create(token: Base64.encode64(opportunity.reference_number))
  end
end
