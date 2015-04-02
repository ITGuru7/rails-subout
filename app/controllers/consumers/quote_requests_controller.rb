class Consumers::QuoteRequestsController < Consumers::BaseController
  skip_before_filter :verify_authenticity_token, only: [:create]
  
  before_filter :check_retailer
  before_filter :check_retailer_host, only: [:new]
  before_filter :check_consumer_quote_request, only: [:select_winner, :show]


  layout 'consumer'

  def new
    @quote_request = QuoteRequest.new
    render :new, layout: 'consumer_embedded_html'
  end

  def create
    @quote_request = @retailer.quote_requests.new(quote_request_params)
    # @quote_request.retailer_host = @retailer_host

    if request.xhr?
      if @quote_request.save
        render :thankyou, layout: false
      else
        render :json=>{ errors: @quote_request.errors, error_messages: @quote_request.errors.full_messages }, status: 422
      end
    else
      if verify_recaptcha(:model => @quote_request, :message => "Oh! It's error with reCAPTCHA!") && @quote_request.save
        render :thankyou, layout: 'consumer_embedded_html'
      else
        @quote_request.valid?
        render :new, layout: 'consumer_embedded_html'
      end
    end
  end

  def show
  end

  def select_winner
    if !@quote_request.awarded?
      @quote_request.win!(@quote.id)
      render :winner
    else
      render :awarded
    end
  end

  private
  def quote_request_params
    params.require(:quote_request).permit(:first_name, :last_name, :email, :email_confirmation, :phone, :vehicle_type, :vehicle_count, :passengers,
      :start_location, :start_date, :start_time, :end_location, :end_date, :end_time, :trip_type, :description)
  end

  def check_retailer
    @retailer = Retailer.where(id: params[:retailer_id]).first
    head :unauthorized if @retailer.blank?
  end

  def check_retailer_host
    return if @retailer.blank?
    @retailer_host = URI.parse(request.referrer).host
    head :unauthorized if !@retailer.valid_domain?(@retailer_host)
  end

  def check_consumer_quote_request
    @quote_request = QuoteRequest.where(reference_number: params[:id], email: params[:consumer_email], retailer_id: params[:retailer_id]).first
    @quote = @quote_request.quotes.where(reference_number: params[:quote_reference_number]).first if !@quote_request.blank?
    head :unauthorized if @quote.blank?
  end

end
