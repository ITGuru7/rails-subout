class Api::V1::EventsController < Api::V1::BaseController
  def index
    events = Event.includes([:actor, :eventable]).recent.page(params[:page]).for(current_company)
    events = events.where(:"action.type" => params[:event_type]) if params[:event_type]

    regions = params[:regions].split(',') unless params[:regions].blank?

    events = events.where(:regions.in => regions) unless regions.blank?
    events = events.where(:cached_eventable_type => params[:opportunity_type]) if params[:opportunity_type]
    events = events.where(:actor_id => params[:company_id]) if params[:company_id]
    events = events.search(params[:q])

    render json: events
  end
end
