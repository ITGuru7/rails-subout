class OpportunitySerializer < ActiveModel::Serializer
  attributes :_id, :name, :description, :start_date, :start_time, :for_favorites_only,
    :end_date, :end_time, :bidding_ends, :bidding_done, :quick_winnable, :bidable?, :image_id, :image_url,
    :winning_bid_id, :win_it_now_price, :type, :canceled, :forward_auction, :winner, :region, :tracking_id, :reference_number

  has_one :buyer, serializer: ActorSerializer

  has_many :bids, serializer: BidShortSerializer

  def winner
    return unless opportunity.winning_bid_id

    winning_bid = opportunity.winning_bid
    {name: winning_bid.bidder.name, amount: winning_bid.amount}
  end

  def image_url
    Cloudinary::Utils.cloudinary_url(opportunity.image_id, width: 200, crop: :scale, format: 'png')
  end
end
