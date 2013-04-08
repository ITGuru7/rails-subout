class Bid
  include Mongoid::Document
  include Mongoid::Timestamps

  field :amount, type: Money
  field :comment, type: String
  field :auto_bidding_limit, type: Money
  paginates_per 30

  belongs_to :opportunity, :inverse_of => :bids
  belongs_to :bidder, class_name: "Company", counter_cache: :bids_count
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
  validate :validate_auto_bidding_limit, on: :create
  validate :validate_auto_bidding_limit_on_win_it_now_price, on: :create
  validates :comment, length: { maximum: 255 }

  scope :recent, desc(:created_at)
  scope :by_amount, asc(:amount)

  after_create :win_quick_winable_opportunity
  after_create :run_automatic_bidding

  def comment_as_seen_by(viewer)
    (viewer == bidder || viewer == opportunity.buyer) ? comment : ""
  end

  def bidding_limit_amount
    auto_bidding_limit ? auto_bidding_limit : amount
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
    return if errors[:amount].present?

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
    return if errors[:amount].present?

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

  def validate_auto_bidding_limit
    return unless opportunity
    return unless auto_bidding_limit.present?
    return if errors[:amount].present?

    if opportunity.forward_auction? and amount > auto_bidding_limit 
      errors.add :auto_bidding_limit, "cannot be lower than amount."
    end

    if !opportunity.forward_auction? and amount < auto_bidding_limit 
      errors.add :auto_bidding_limit, "cannot be higher than amount."
    end
  end

  def validate_auto_bidding_limit_on_win_it_now_price
    return unless opportunity
    return unless auto_bidding_limit.present?
    return unless opportunity.win_it_now_price.present?

    if opportunity.forward_auction? and opportunity.win_it_now_price <= auto_bidding_limit
      errors.add :auto_bidding_limit, "cannot be lower than win it now price."
    end

    if !opportunity.forward_auction? and opportunity.win_it_now_price >= auto_bidding_limit
      errors.add :auto_bidding_limit, "cannot be higher than win it now price."
    end
  end

  # Forward auction
  # first  500, 800 => 701
  # second 600, 700 => 700
  # third  620, 650 => 650
  #
  # Reverse auction
  # first  800, 500 => 599
  # second 700, 600 => 600
  # third  650, 620 => 620
  def run_automatic_bidding
    return unless opportunity.bids.size > 1

    leading_bid_amount = opportunity.leading_bid_amount
    opportunity.bids.select { |b| b.auto_bidding_limit.present? }.each do |bid|
      if opportunity.forward_auction
        if bid.amount < leading_bid_amount and bid.amount < bid.auto_bidding_limit
          new_amount = [bid.auto_bidding_limit, leading_bid_amount].min
          bid.update_attribute(:amount, new_amount)
        end
      else
        if bid.amount > leading_bid_amount and bid.amount > bid.auto_bidding_limit
          new_amount = [bid.auto_bidding_limit, leading_bid_amount].max
          bid.update_attribute(:amount, new_amount)
        end
      end
    end
  end
end
