class OpportunitySerializer < ActiveModel::Serializer
  attributes :_id, :name, :description, :start_date, :start_time, :for_favorites_only, :start_region, :end_region,
    :end_date, :end_time, :bidding_duration_hrs, :bidding_ends_at, :bidding_done, :quick_winnable, :bidable?, :image_id,
    :winning_bid_id, :win_it_now_price, :type, :canceled, :forward_auction, :winner, :tracking_id, :reference_number,
    :buyer_name, :buyer_abbreviated_name, :image_url, :large_image_url, :start_location, :end_location, :created_at, :status, :buyer_id

  has_one :buyer, serializer: ActorSerializer

  has_many :recent_bids, serializer: BidShortSerializer, key: "bids"

  def winner
    return unless opportunity.winning_bid_id

    winning_bid = opportunity.winning_bid
    {name: winning_bid.bidder.name, amount: winning_bid.amount}
  end

  def image_url
    Cloudinary::Utils.cloudinary_url(opportunity.image_id, width: 200, crop: :scale, format: 'png')
  end

  def large_image_url
    Cloudinary::Utils.cloudinary_url(opportunity.image_id, width: 500, crop: :scale, format: 'png')
  end

  def buyer_name
    opportunity.buyer.name
  end

  def buyer_abbreviated_name
    opportunity.buyer.abbreviated_name
  end

  def start_date
    opportunity.start_date.strftime("%Y/%m/%d") if opportunity.start_date
  end

  def end_date
    opportunity.end_date.strftime("%Y/%m/%d") if opportunity.end_date
  end
end
