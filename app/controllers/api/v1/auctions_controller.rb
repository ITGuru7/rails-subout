class Api::V1::AuctionsController < Api::V1::BaseController
  def index
    params[:page] ||= 1
    sort_by = params[:sort_by] || "created_at"
    sort_direction = params[:sort_direction] || "desc"
    query = params[:query] == "undefined" ? nil : params[:query]
    opportunities = current_company.auctions.active.order_by(sort_by => sort_direction)
    opportunities = opportunities.search(query) if query.present?
    meta = {
      :count =>  opportunities.count,
      :per_page => Opportunity.default_per_page,
      :page => params[:page].to_i,
    }
    render json: opportunities.page(params[:page]), root: "opportunities", meta: meta
  end

  def create
    if params[:opportunity][:clone]
      white_listed_fields = %W{
        name type tracking_id description image_id contact_phone start_location end_location
        start_date start_time end_date end_time bidding_duration_hrs ada_required for_favorites_only
        forward_auction quick_winnable win_it_now_price reserve_amount vehicle_type trip_type vehicle_count special_region
      }
      @auction = Opportunity.new(params[:opportunity].slice(*white_listed_fields))
    else
      @auction = Opportunity.new(params[:opportunity])
    end
    @auction.buyer = current_company

    @auction.save

    respond_with_namespace(@auction)
  end

  def update
    @auction = current_company.auctions.find(params[:id])

    if @auction.editable?
      @auction.update!(params[:opportunity])
      respond_with_namespace(@auction)
    else
      render json: { errors: { base: ["This opportunity is not editable."] } }, status: :unprocessable_entity
    end
  end

  def show
    @auction = current_company.auctions.find(params[:id])
    @auction.viewer = current_company
    respond_with_namespace(@auction)
  end

  def select_winner
    @auction = current_company.auctions.find(params[:id])
    if @auction.canceled?
      render json: { errors: { base: ["This opportunity is canceled."] } }, status: :unprocessable_entity
    elsif @auction.awarded?
      render json: { errors: { base: ["This opportunity is already awarded by another bidder."] } }, status: :unprocessable_entity
    else
      @auction.win!(params[:bid_id])
      render json: {}
    end
  end

  def create_negotiation
    @auction = current_company.auctions.find(params[:id])
    @auction.start_negotiation!(params[:bid][:id], params[:bid][:amount])

    @serializer = OpportunitySerializer.new(@auction)
    render json: @serializer
  end


  def cancel
    @auction = Opportunity.find(params[:id])
    unless (@auction.canceled? or @auction.awarded?)
      @auction.cancel!
      render json: {}
    else
      render json: { errors: { base: ["This opportunity cannot be canceled"] } }, status: :unprocessable_entity
    end
  end

  def award
    @auction = Opportunity.find(params[:id])
    unless (@auction.canceled? or @auction.awarded?)
      @auction.award!
      render json: {}
    else
      render json: { errors: { base: ["This opportunity cannot be awarded"] } }, status: :unprocessable_entity
    end
  end
end
