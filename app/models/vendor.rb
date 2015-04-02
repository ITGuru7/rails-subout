class Vendor
  include Mongoid::Document

  field :name,        :type => String
  field :email,       :type => String
  field :address,     :type => String
  field :crm_id,      :type => String

  has_many :offers

  validates_presence_of :email
  validates_uniqueness_of :email

  before_save do
    self.email.downcase! if self.email
  end

  def self.find_by_email(email)
    where(:email => email).first
  end

  def total_invited_amount
    self.offers.active.sum(&:amount)
  end

  def total_won_amount
    self.offers.accepted.sum(&:amount)
  end
end
