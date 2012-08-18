SimpleRoles.configure do |config|
  config.valid_roles = [:member, :admin, :guest]
  config.strategy = :one
end
