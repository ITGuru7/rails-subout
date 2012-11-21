class Bid
  include Mongoid::Document
  include Mongoid::Timestamps

  field :amount, type: BigDecimal

  belongs_to :opportunity
  belongs_to :bidder, :class_name => "Company"

  validates_presence_of :bidder_id, :on => :create, :message => "can't be blank"
  validates_presence_of :opportunity_id, :on => :create, :message => "can't be blank"
  validates_presence_of :amount, :on => :create, :message => "can't be blank"
  validate :validate_opportunity_bidable
  validate :validate_bidable_by_bidder
  validate :validate_multiple_bids_on_the_same_opportunity

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
    unless opportunity.bidable?
      errors.add :base, "opportunity has been closed"
    end
  end

  def validate_bidable_by_bidder
    unless opportunity.buyer_id != bidder_id
      errors.add :bidder_id, "cannot bid on your own opportunity"
    end
  end

  def validate_multiple_bids_on_the_same_opportunity
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
