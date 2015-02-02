class Consumers::QuoteRequestsController < Consumers::BaseController
  skip_before_filter :authenticate_consumer!, only: [:create]
  skip_before_filter :verify_authenticity_token, only: [:create]
  
  before_filter :check_consumer

  layout false

  def new
    @quote_request = QuoteRequest.new
  end

  def create
    @quote_request = @consumer.quote_requests.new(quote_request_params)
    @quote_request.consumer_host = @consumer_host
    if @quote_request.save
      render :thankyou
    else
      render :json=>{ errors: @quote_request.errors, error_messages: @quote_request.errors.full_messages }, status: 422
    end
  end

  private
  def quote_request_params
    params.require(:quote_request).permit(:first_name, :last_name, :email, :phone, :vehicle_type, :vehicle_count, :passengers,
      :start_location, :start_date, :start_time, :end_location, :end_date, :end_time, :trip_type, :description)
  end

  def check_consumer
    @consumer = Consumer.where(id: params[:consumer_id]).first
    @consumer_host = URI.parse(request.referrer).host
    head :unauthorized if @consumer.blank? or !@consumer.valid_domain?(@consumer_host)
  end
end
