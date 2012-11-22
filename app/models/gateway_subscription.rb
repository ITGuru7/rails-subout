class GatewaySubscription
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email
  field :first_name
  field :last_name
  field :organization
  field :subscription_id
  field :customer_id
  field :product_handle

  belongs_to :company

  scope :pending, where(company_id: nil)
end
