class ActorSerializer < ActiveModel::Serializer
  attributes :_id, :name, :abbreviated_name, :logo_url

  def logo_url
    Cloudinary::Utils.cloudinary_url(actor.logo_id, width: 180, crop: :scale, format: 'png')
  end
end
