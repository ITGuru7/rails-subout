class GatewaySubscriptionSerializer < ActiveModel::Serializer
  attributes :_id, :created_at, :email, :first_name, :last_name, :organization
end
