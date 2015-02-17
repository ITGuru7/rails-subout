class QuoteRequestSerializer < ActiveModel::Serializer
  attributes :_id, :created_at, :name, :email, :vehicle_count, :vehicle_type, :trip_type, :reference_number, :start_date, :end_date, :start_region, :end_region, :description,
    :bidding_ends_at, :quotable, :for_quote_only

  has_many :recent_quotes, array_seralizer: QuoteShortSerializer

  def name
    "#{object.first_name} #{object.last_name}"
  end

  def bidding_ends_at
    object.created_at + 48.hours
  end

  def quotable
    object.quotable?
  end

  def for_quote_only
    true
  end
end
