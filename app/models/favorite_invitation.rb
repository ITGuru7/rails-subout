require 'securerandom'

class FavoriteInvitation
  include Mongoid::Document

  field :supplier_name, type: String
  field :supplier_email, type: String
  field :token, type: String, default: ->{ SecureRandom.uuid }

  belongs_to :buyer, :class_name => "Company"
  belongs_to :supplier, :class_name => "Company"

  def accept!
    buyer.add_favorite_supplier!(supplier)
  end

end
