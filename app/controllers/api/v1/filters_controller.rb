class Api::V1::FiltersController < Api::V1::BaseController
  def index
    render :file => "#{Rails.root}/public/api/v1/_filters", :formats => [:json]
  end
end
