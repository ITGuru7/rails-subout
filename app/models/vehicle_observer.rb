class VehicleObserver < Mongoid::Observer
  observe :vehicle

  def after_create(vehicle)
    update_vehicle_count(vehicle)
  end

  def after_destroy(vehicle)
    update_vehicle_count(vehicle)
  end

  private

  def update_vehicle_count(vehicle)
    company = vehicle.company
    subscription = company.created_from_subscription
    return unless subscription

    if subscription.vehicle_count != company.vehicles.count
      subscription.update_vehicle_count!(company.vehicles.count)
    end
  end
end
