class Api::V1::OffersController < Api::V1::BaseController

  def create
    offer = opportunity.build_offer(offer_params)
    offer.vendor = vendor
    if offer.save
      opportunity.award!
    end
    respond_with_namespace(offer.opportunity, offer)
  end

  private

  def opportunity
    @opportunity ||= Opportunity.find(params[:opportunity_id])
  end
  
  def offer_params
    params.require(:offer).permit(:amount, :vehicle_type)
  end

  def vendor_params
    params.require(:vendor).permit(:id, :name, :email, :crm_id)
  end

  def vendor
    @vendor = Vendor.where(email: vendor_params[:email]).first
    if @vendor.blank? && !vendor_params.blank?
      @vendor = Vendor.create(vendor_params)
    end
    @vendor
  end
end
