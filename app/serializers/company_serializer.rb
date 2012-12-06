class CompanySerializer < ActiveModel::Serializer
  attributes :_id, :name, :email, :logo_url, :logo_id, :regions, :website,
    :fleet_size, :since, :owner, :contact_name, :tpa, :abbreviated_name, :contact_phone,
    :bids_count, :opportunities_count, :state_by_state_subscriber?, :favoriting_buyer_ids

  def logo_url
    Cloudinary::Utils.cloudinary_url(company.logo_id, width: 200, crop: :scale, format: 'png')
  end

  def bids_count
    company.bids.count
  end

  def opportunities_count
    company.auctions.count
  end
end
