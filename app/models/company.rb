class Company
  include Mongoid::Document
  field :name, type: String
  field :hq_location_id, type: Integer
  field :active, type: Boolean
  field :company_msg_path, type: String
  after_initialize :init

  has_many :users
  has_many :opportunities
  
  validates_presence_of :name, :on => :create, :message => "can't be blank"
  validates_presence_of :company_msg_path, :on => :create, :message => "can't be blank"
  
  def init
  	self.company_msg_path  ||= UUID.new.generate
  end

  def interested_in_event?(event)
  	true
  end

  def send_event(event, associated_object)
    Rails.logger.info "Queing event to be sent to path #{company_msg_path}"
  	event.delay.send_msg(company_msg_path, associated_object)
  end
end
