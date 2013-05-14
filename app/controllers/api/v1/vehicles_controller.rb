class Api::V1::VehiclesController < Api::V1::BaseController
  def create
    @vehicle = Vehicle.new(params[:vehicle])
    @vehicle.company = current_user.company
    @vehicle.save
    current_user.company.update_vehicle_count()

    respond_with_namespace(@vehicle)
  end

  def update
    @vehicle = Vehicle.find(params[:id])
    @vehicle.update_attributes(params[:vehicle])

    repond_with_namespace(@vehicle)
  end

  def destroy
    @vehicle = Vehicle.find(params[:id])
    @vehicle.delete
    current_user.company.update_vehicle_count()

    render json: {}
  end
end
