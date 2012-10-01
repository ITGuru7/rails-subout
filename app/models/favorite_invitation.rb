require 'securerandom'

class FavoriteInvitation
  include Mongoid::Document

  field :supplier_name, type: String
  field :supplier_email, type: String
  field :custom_message, type: String
  field :token, type: String, default: ->{ SecureRandom.uuid }
  field :accepted, type: Boolean, default: false

  scope :pending, where(:accepted => false)

  belongs_to :buyer, :class_name => "Company"
  belongs_to :supplier, :class_name => "Company"

  has_one :created_company, :class_name => "Company"

  def accept!
    buyer.add_favorite_supplier!(supplier)
    self.update_attribute(:accepted, true)
  end

  def pending?
    !accepted
  end

end
