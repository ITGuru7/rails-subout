class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :token_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable

  before_save :ensure_authentication_token

  ## Database authenticatable
  field :email,              :type => String
  field :encrypted_password, :type => String

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String
  field :remind_email_sent, type: Boolean, default: false

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  field :locked_at,       :type => Time

  ## Token authenticatable
  field :authentication_token, :type => String

  ## Belongs to companies
  field :company_id, :type => String

  belongs_to :company, :class_name => "Company", :foreign_key => "company_id"
  has_many :mobile_keys
  validates_presence_of :email, :on => :create, :message => "can't be blank"

  ## Needed for simple_role and cancan
  field :role, :type => String

  before_save do
    self.email.downcase! if self.email
  end

  def self.find_by_email(email)
    where(:email => email).first
  end

  def self.send_remind_notification
    User.all.each do |user|
      next if user.company_id.nil?

      if user.last_sign_in_at < 3.days.ago and user.remind_email_sent == false
        user.remind_email_sent = true

        Notifier.delay.remind_to_user(user.id)
        Notifier.delay.remind_to_admin(user.id)
      else
        user.remind_email_sent = false
      end
      user.save
    end
  end

  def auth_token_hash
    {
      api_token: authentication_token,
      authorized: true,
      company_id: company_id,
      user_id: _id,
      pusher_key: Pusher.key
    }
  end

end
