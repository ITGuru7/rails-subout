class Api::V1::EventsController < Api::V1::BaseController
  def index
    events = Event.recent.page(params[:page]).for(current_company)
    events = events.where(:"action.type" => params[:event_type]) if params[:event_type]
    events = events.where(:regions => params[:region]) if params[:region]
    events = events.where(:cached_eventable_type => params[:opportunity_type]) if params[:opportunity_type]
    events = events.where(:actor_id => params[:company_id]) if params[:company_id]
    query = params[:q]
    if query.present? and query.start_with?("#")
      events = events.where(eventable_reference_number: query[1..-1])
    else
      events = events.full_text_search(query)
    end
    respond_with_namespace events
  end
end
