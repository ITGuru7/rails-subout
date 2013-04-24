class Api::V1::RatingsController < Api::V1::BaseController
  def update
    @rating = Rating.find(params[:id])
    if @rating.editable
      @rating.update_attributes(params[:rating])
      @rating.lock!
      respond_with_namespace(@rating)
    else
      render json: { errors: { editable: "Rating is locked." } }, status: 404
    end
  end
end
