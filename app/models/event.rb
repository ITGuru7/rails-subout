class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Search

  field :regions, type: Array
  field :eventable_company_id
  field :eventable_for_favorites_only
  field :cached_eventable_type
  field :eventable_reference_number

  belongs_to :actor, :class_name => "Company", index: true
  embeds_one :action, class_name: "EventAction"
  belongs_to :eventable, class_name: "Opportunity", index: true

  index eventable_company_id: 1
  index cached_eventable_type: 1
  index created_at: 1
  index updated_at: 1
  index "action.type" => 1

  paginates_per 30
  search_in eventable: :fulltext

  before_create :copy_eventable_fields

  def self.recent
    order_by(:updated_at => :desc).includes(:actor)
  end

  def self.for(company)
    events = Array.new

    options = [
      {:eventable_company_id.in => company.favoriting_buyer_ids + [company.id]},
      {:eventable_for_favorites_only => false}
    ]

    self.any_of(*options)
  end

  def self.search(query)
    if query.present? and query.start_with?("#")
      query = query[1..-1]
    end

    self.full_text_search(query)
  end

  private

  def copy_eventable_fields
    self.regions = eventable.regions
    self.cached_eventable_type = eventable.type
    self.eventable_for_favorites_only = eventable.for_favorites_only
    self.eventable_company_id = eventable.buyer_id
    self.eventable_reference_number = eventable.reference_number
  end
end
