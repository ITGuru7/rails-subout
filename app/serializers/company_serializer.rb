class CompanySerializer < ActiveModel::Serializer
  attributes :_id, :name, :email, :logo, :region, 
    :fleet_size, :since, :owner, :contact_name, :tpa

  def logo
    "img/company/#{company.id}.png"
  end
end
