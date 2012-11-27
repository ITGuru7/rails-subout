class Api::V1::EventsController < Api::V1::BaseController
  def index
    respond_with_namespace Event.recent.for(current_company)
  end
end
