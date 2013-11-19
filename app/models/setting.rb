class Setting
  include Mongoid::Document
  include Mongoid::Timestamps

  field :key
  field :value
  
  validates_presence_of :value
  validate :validate_santinized_length, if: :application_message? 

  def to_param
    key
  end

  def to_s
    key.gsub("_", " ").capitalize
  end

  def label
    key.split('_').last.capitalize
  end

  def self.admin_email
    Setting.find_by(key: 'admin_email').value
  end

  def application_message?
    self.key == "application_message"
  end

  def validate_santinized_length
    return unless value

    striped_value = HTML::FullSanitizer.new.sanitize(value)
    if striped_value.length > 200
      errors.add(:santinized_length, "cannot be greater than 200")
    end
  end
end
