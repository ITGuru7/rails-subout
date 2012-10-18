class Api::V1::EventsController < Api::V1::BaseController
  def index
    render :json => Event.recent.to_json(:methods => [:eventable, :initiated_by_name])
  end
end
