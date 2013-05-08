class Api::V1::VehiclesController < Api::V1::BaseController
  def create
    vehicle = Vehicle.new(params[:vehicle])
    vehicle.company = current_user.company
    vehicle.save
    render json: {}
  end

  def update
    vehicle = Vehicle.find(params[:id])
    vehicle.update_attributes(params[:vehicle])
    render json: {}
  end

  def destroy
    vehicle = Vehicle.find(params[:id])
    vehicle.delete
    render json: {}
  end
end
