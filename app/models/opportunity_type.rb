class OpportunityType
  include Mongoid::Document
  field :name, type: String
  belongs_to :opportunity
  
end
