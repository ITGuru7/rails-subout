class CompanySerializer < ActiveModel::Serializer
  attributes :_id, :name, :email, :logo_url, :logo_id, :regions, :website, :notification_type,
    :fleet_size, :since, :owner, :contact_name, :tpa, :abbreviated_name, :contact_phone,
    :bids_count, :opportunities_count, :state_by_state_subscriber?, :favoriting_buyer_ids, :self_service_url,
    :dot_number, :cell_phone, :sales_info_messages, :subscription_plan, :insurance, :upgraded_recently, :has_ada_vehicles, :payment_state, 
    :vehicles, :notification_email, :score

  has_many :ratings_taken, serializer: RatingSerializer

  def score
    return 0.0 if object.ratings_taken.blank?
    sum = 0.0
    count = 0

    object.ratings_taken.each{|rating|
      sum = sum + rating.score
      count = count + 1 if rating.score != 0
    }

    return 0.0 if count == 0
    return sum / count 
  end

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
    return false unless scope
    scope.id == object.id
  end

  def payment_state
    object.created_from_subscription.try(:payment_state)
  end

  def include_payment_state?
    return false unless scope
    scope.id == object.id
  end

  def include_self_service_url?
    return false unless scope
    scope.id == object.id
  end

  def self_service_url
    MyChargify.self_service_url(object.created_from_subscription.try(:subscription_id))
  end
end
