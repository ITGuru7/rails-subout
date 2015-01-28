class Consumers::ProfilesController < Consumers::BaseController
  def edit
    @consumer = current_consumer
  end

  def update
    current_consumer.update_attributes(consumer_params) 
    redirect_to edit_consumers_profile_path
  end

  private
  def consumer_params
    params.require(:consumer).permit(:domains)
  end
end
