class Consumers::QuoteRequestsController < Consumers::BaseController
  skip_before_filter :authenticate_consumer!
  layout false

  def new
    @quote_request = QuoteRequest.new
  end

  def create
    @quote_request = QuoteRequest.new(quote_request_params)
    if @quote_request.save
      render :thankyou
    else
      render :json=>{ errors: @quote_request.errors, error_messages: @quote_request.errors.full_messages }, status: 422
    end
  end

  def embedded_script
    @quote_request = QuoteRequest.new
  end

  def embedded_html
    @quote_request = QuoteRequest.new
  end

  private
  def quote_request_params
    params.require(:quote_request).permit(:first_name, :last_name, :email, :phone, :vehicle_type, :vehicle_count, :passengers, 
      :pick_up_location, :pick_up_date, :drop_off_location, :drop_off_date, :trip_type, :description)
  end
end
