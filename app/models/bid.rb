class Bid
  include Mongoid::Document
  include Mongoid::Timestamps

  field :amount, type: BigDecimal
  field :comment, type: String

  belongs_to :opportunity
  belongs_to :bidder, :class_name => "Company"

  validates_presence_of :bidder_id, :on => :create, :message => "can't be blank"
  validates_presence_of :opportunity_id, :on => :create, :message => "can't be blank"
  validates_presence_of :amount, :on => :create, :message => "can't be blank"
  validates :amount, numericality: { greater_than: 0 }
  validate :validate_opportunity_bidable, :on => :create
  validate :validate_bidable_by_bidder, :on => :create
  validate :validate_multiple_bids_on_the_same_opportunity, :on => :create

  scope :recent, desc(:created_at)
  scope :by_amount, asc(:amount)

  after_create :win_quick_winable_opportunity

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

    if opportunity.for_favorites_only?
      unless opportunity.buyer.favoriting_buyer_ids.include?(bidder.id)
        errors.add :bidder_id, "cannot bid on an opportunity that is for favorites only"
      end
    else
      unless bidder.subscribed?(opportunity.regions)
        errors.add :bidder_id, "cannot bid on an opportunity within this region"
      end
    end
  end

  def validate_multiple_bids_on_the_same_opportunity
    return unless opportunity

    previous_bids = opportunity.bids.where(bidder_id: bidder.id, :id.ne => self.id)
    if opportunity.forward_auction?
      max_amount = previous_bids.max(:amount)
      if max_amount && amount <= BigDecimal.new(max_amount.to_s)
        errors.add :amount, "cannot be lower than previous bid"
      end
    else
      min_amount = previous_bids.min(:amount)
      if min_amount && amount >= BigDecimal.new(min_amount.to_s)
        errors.add :amount, "cannot be higher than previous bid"
      end
    end
  end
end
