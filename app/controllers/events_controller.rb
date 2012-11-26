class EventsController < ApplicationController
  def index
    @events = Event.recent.for(current_company)
  end
end
