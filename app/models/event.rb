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
  belongs_to :eventable, index: true, polymorphic: true

  index eventable_company_id: 1
  index created_at: 1
  index updated_at: 1

  paginates_per 30
  search_in eventable: :fulltext

  before_create :copy_eventable_fields

  def self.recent
    order_by(:updated_at => :desc).includes(:actor)
  end

  def self.for(company)

    options = [
      {:eventable_company_id.in => company.favoriting_buyer_ids + [company.id]},
      {:eventable_company_id=>nil},
      {:eventable_for_favorites_only => false}
    ]

    self.any_of(*options)
  end

  def self.search(query)
    if query.present? and query.start_with?("#")
      query = query[1..-1]
    end

    where(_keywords: query.downcase)
  end

  private

  def copy_eventable_fields
    if self.eventable_type=='Opportunity'
      self.regions = eventable.regions
      self.cached_eventable_type = eventable.type
      self.eventable_for_favorites_only = eventable.for_favorites_only
      self.eventable_company_id = eventable.buyer_id
      self.eventable_reference_number = eventable.reference_number
    else
      self.regions = eventable.regions
      self.eventable_reference_number = eventable.reference_number
    end
  end
end
