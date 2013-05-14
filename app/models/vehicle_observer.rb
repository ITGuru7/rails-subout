class VehicleObserver < Mongoid::Observer
  observe :vehicle

  def after_create(vehicle)
    Notifier.delay.new_vehicle(vehicle.id)
  end

  def after_destroy(vehicle)
    Notifier.delay.remove_vehicle(vehicle, vehicle.company_id)
  end
end
