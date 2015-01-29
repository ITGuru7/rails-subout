class QuoteRequestObserver < Mongoid::Observer
  observe :quote_request

  def after_create(quote_request)
    create_event(quote_request, :quote_request_created)
  end

  def create_event(quote_request, type)
    Event.create!(action: {type: type}, eventable: quote_request)
  end
end
