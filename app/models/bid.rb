class Bid
  include Mongoid::Document
  include Mongoid::Timestamps

  field :amount, type: BigDecimal

  has_one :event, :as => :eventable

  belongs_to :opportunity
  belongs_to :bidder, :class_name => "Company"

  validates_presence_of :bidder_id, :on => :create, :message => "can't be blank"
  validates_presence_of :opportunity_id, :on => :create, :message => "can't be blank"
  validates_presence_of :amount, :on => :create, :message => "can't be blank"
  validate :validate_multiple_bids_on_the_same_opportunity

  scope :recent, desc(:created_at)
  scope :by_amount, asc(:amount)

  after_create :win_quick_winable_opportunity

  def initiated_by_name
    bidder.name
  end

  def self.latest_amount
    recent.first.try(:amount)
  end

  def self.lowest_amount
    by_amount.first.try(:amount)
  end

  def type
    'Bid'
  end

  def opportunity_bidding_ends
    opportunity.bidding_ends
  end

  def opportunity_title
    opportunity.name
  end

  def formatted_amount
    ActionController::Base.helpers.number_to_currency(amount, :unit=>'')
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

  def validate_multiple_bids_on_the_same_opportunity
    if opportunity.forward_auction?
      max_amount = opportunity.bids.where(bidder_id: bidder.id).max(:amount)
      if max_amount && amount <= BigDecimal.new(max_amount)
        errors.add :amount, "cannot be lower than previous bid"
      end
    else
      min_amount = opportunity.bids.where(bidder_id: bidder.id).min(:amount)
      if min_amount && amount >= BigDecimal.new(min_amount)
        errors.add :amount, "cannot be higher than previous bid"
      end
    end
  end
end
