class QuoteRequestShortSerializer < ActiveModel::Serializer
  attributes :_id, :created_at, :name, :trip_type, :vehicle_count, :vehicle_type, :reference_number, :start_date, :end_date, :start_region, :end_region, :description, :bidding_ends_at

  def name
    "#{object.first_name} #{object.last_name}"
  end

  def bidding_ends_at
    object.created_at + 48.hours
  end
end