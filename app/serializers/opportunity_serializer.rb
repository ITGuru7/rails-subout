class OpportunitySerializer < ActiveModel::Serializer
  attributes :_id, :name, :description, :start_date, :start_time, :for_favorites_only, :start_region, :end_region,
    :end_date, :end_time, :bidding_duration_hrs, :bidding_ends_at, :bidding_done, :quick_winnable, :bidable?, :image_id,
    :winning_bid_id, :win_it_now_price, :type, :vehicle_type, :canceled, :forward_auction, :winner, :tracking_id, :reference_number,
    :buyer_name, :buyer_abbreviated_name, :image_url, :large_image_url, :start_location, :end_location, :created_at, :status, :buyer_id, :contact_phone,
    :highest_bid_amount, :lowest_bid_amount, :reserve_amount, :ada_required, :start_date, :icon

  has_one :buyer, serializer: ActorSerializer

  has_many :recent_bids, serializer: BidShortSerializer, key: "bids"
  has_many :comments, serializer: CommentSerializer

  def icon
    "icon-#{object.type.parameterize}"
  end

  def winner
    return unless object.winning_bid_id

    winning_bid = object.winning_bid
    {name: winning_bid.bidder.name, amount: winning_bid.amount}
  end

  def image_url
    Cloudinary::Utils.cloudinary_url(object.image_id, width: 200, crop: :scale, format: 'png')
  end

  def large_image_url
    Cloudinary::Utils.cloudinary_url(object.image_id, width: 500, crop: :scale, format: 'png')
  end

  def buyer_name
    object.buyer.name
  end

  def buyer_abbreviated_name
    object.buyer.abbreviated_name
  end

  def start_date
    object.start_date.strftime("%Y/%m/%d") if object.start_date
  end

  def end_date
    object.end_date.strftime("%Y/%m/%d") if object.end_date
  end

  def win_it_now_price
    return nil unless object.win_it_now_price.present?

    object.win_it_now_price.to_i
  end

  def bidding_ends_at
    object.bidding_ends_at.getutc.iso8601
  end
end
