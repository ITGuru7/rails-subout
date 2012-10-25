class Api::V1::TagsController < Api::V1::BaseController
  def index
    render :file => "#{Rails.root}/public/api/v1/_tags", :formats => [:json]
  end
end
