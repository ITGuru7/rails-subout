class Setting
  include Mongoid::Document
  include Mongoid::Timestamps

  field :key
  field :value

  def to_param
    key
  end
end
