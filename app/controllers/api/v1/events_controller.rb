class Api::V1::EventsController < Api::V1::BaseController
  def index
    respond_with_namespace Event.recent.page(params[:page]).for(current_company)
  end
end
