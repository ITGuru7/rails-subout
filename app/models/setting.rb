class Setting
  include Mongoid::Document
  include Mongoid::Timestamps

  field :key
  field :value

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
    Setting.find(key: 'admin_email').value
  end
end
