class CompanySerializer < ActiveModel::Serializer
  attributes :_id, :name, :email, :logo, :regions, 
    :fleet_size, :since, :owner, :contact_name, :tpa,
    :bids_count, :opportunities_count, :state_by_state_subscriber?

  def logo
    "img/company/#{company.id}.png"
  end

  def bids_count
    company.bids.count
  end

  def opportunities_count
    company.auctions.count
  end
end
