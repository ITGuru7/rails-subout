require 'securerandom'

class Company
  include Mongoid::Document
  field :name, type: String
  field :hq_location_id, type: String

  #TODO remove this once we figure out where it's being used
  field :active, type: Boolean

  field :company_msg_path, type: String, default: ->{ SecureRandom.uuid }
  field :member, type: Boolean, default: false

  has_many :users
  has_many :opportunities
  has_many :favorites
  has_many :contacts
  has_many :locations

  validates_presence_of :name, :on => :create, :message => "can't be blank"
  validates_presence_of :company_msg_path, :on => :create, :message => "can't be blank"
  
  def interested_in_event?(event)
  	true
  end

  def guest? 
    !member?
  end

  def send_event(event, associated_object)
    Rails.logger.info "Queing event to be sent to path #{company_msg_path}"
  	event.delay.send_msg(company_msg_path, associated_object)
  end

end
