class Bid
  include Mongoid::Document
  include Mongoid::Timestamps

  field :amount, type: BigDecimal
  field :comment, type: String

  belongs_to :opportunity, :inverse_of => :bids
  belongs_to :bidder, class_name: "Company"
  has_one :won_opportunity, :class_name => "Opportunity", :foreign_key => "winning_bid_id", :inverse_of => :winning_bid

  validates_presence_of :bidder_id, on: :create, message: "can't be blank"
  validates_presence_of :opportunity_id, on: :create, message: "can't be blank"
  validates_presence_of :amount, on: :create, message: "can't be blank"
  validates :amount, numericality: { greater_than: 0 }
  validate :validate_opportunity_bidable, on: :create
  validate :validate_bidable_by_bidder, on: :create
  validate :validate_multiple_bids_on_the_same_opportunity, on: :create
  validate :validate_reserve_met, on: :create
  validate :validate_dot_number_of_bidder, on: :create
  validates :comment, length: { maximum: 255 }

  scope :recent, desc(:created_at)
  scope :by_amount, asc(:amount)

  after_create :win_quick_winable_opportunity

  def comment_as_seen_by(viewer)
    (viewer == bidder || viewer == opportunity.buyer) ? comment : ""
  end

  private

  def win_quick_winable_opportunity
    return unless opportunity.quick_winnable

    opportunity.win!(self.id) if quick_win_forward_auction? or quick_win_reverse_auction?
  end

  def quick_win_forward_auction?
    opportunity.forward_auction? and opportunity.win_it_now_price <= self.amount
  end

  def quick_win_reverse_auction?
    !opportunity.forward_auction? and opportunity.win_it_now_price >= self.amount 
  end

  def validate_opportunity_bidable
    return unless opportunity

    unless opportunity.bidable?
      errors.add :base, "opportunity has been closed"
    end
  end

  def validate_bidable_by_bidder
    return unless opportunity

    unless opportunity.buyer_id != bidder_id
      errors.add :bidder_id, "cannot bid on your own opportunity"
    end

    unless bidder.is_a_favorite_of?(opportunity.buyer)
      if opportunity.for_favorites_only?
        errors.add :bidder_id, "cannot bid on an opportunity that is for favorites only"
      elsif !bidder.subscribed?(opportunity.regions)
        errors.add :bidder_id, "cannot bid on an opportunity within this region"
      end
    end
  end

  def validate_multiple_bids_on_the_same_opportunity
    return unless opportunity
    return if errors[:amount]

    previous_bids = opportunity.bids.where(bidder_id: bidder.id, :id.ne => self.id)
    if opportunity.forward_auction?
      max_amount = previous_bids.map(&:amount).max
      if max_amount && amount <= BigDecimal.new(max_amount.to_s)
        errors.add :amount, "cannot be lower than previous bid"
      end
    else
      min_amount = previous_bids.map(&:amount).min
      if min_amount && amount >= BigDecimal.new(min_amount.to_s)
        errors.add :amount, "cannot be higher than previous bid"
      end
    end
  end

  def validate_reserve_met
    return unless opportunity
    return unless opportunity.reserve_amount.present?
    return if errors[:amount]

    if opportunity.forward_auction?
      if amount < opportunity.reserve_amount
        errors.add :amount, "cannot be lower than reserve"
      end
    else
      if amount > opportunity.reserve_amount
        errors.add :amount, "cannot be higher than reserve"
      end
    end
  end

  def validate_dot_number_of_bidder
    return unless bidder

    if bidder.dot_number.blank?
      errors.add :bidder_id, "required DOT number to bid."
    end
  end
end
