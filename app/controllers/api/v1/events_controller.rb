class Api::V1::EventsController < Api::V1::BaseController
  def index
    events = Event.recent.page(params[:page]).for(current_company)
    events = events.where(:"action.type" => params[:event_type]) if params[:event_type]
    events = events.where(:"regions" => params[:region]) if params[:region]
    events = events.where(:cached_eventable_type => params[:opportunity_type]) if params[:opportunity_type]
    respond_with_namespace events
  end
end
