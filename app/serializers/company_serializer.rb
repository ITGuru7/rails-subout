class CompanySerializer < ActiveModel::Serializer
  attributes :_id, :name, :email, :logo_url, :logo_id, :regions, :website, :notification_type,
    :fleet_size, :since, :owner, :contact_name, :tpa, :abbreviated_name, :contact_phone,
    :bids_count, :opportunities_count, :state_by_state_subscriber?, :favoriting_buyer_ids,
    :dot_number, :cell_phone, :sales_info_messages

  def logo_url
    Cloudinary::Utils.cloudinary_url(object.logo_id, width: 200, crop: :scale, format: 'png')
  end

  def bids_count
    object.bids.count
  end

  def opportunities_count
    object.auctions.count
  end

  def include_sales_info_messages?
    scope.id == object.id
  end
end
