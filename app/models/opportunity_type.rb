#TODO remove this and scaffolded controller
class OpportunityType
  include Mongoid::Document
  field :name, type: String
  has_many :opportunities
end
