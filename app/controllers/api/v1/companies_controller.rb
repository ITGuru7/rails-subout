class Api::V1::CompaniesController < Api::V1::BaseController
  def new_supplier
    invitation = FavoriteInvitation.where(:token => params[:id]).first

    if invitation
      @new_supplier = Company.new(
        name: invitation.supplier_name,
        email: invitation.supplier_email,
        created_from_invitation_id: invitation.id
      )
    else
      redirect_to :root,
        :notice => 'Your invitation was not found please check your email again and ensure you copy the entire link.' 
    end
  end

  def create
    @new_supplier = Company.new(params[:company])
    if @new_supplier.save
      invitation = @new_supplier.created_from_invitation
      invitation.supplier = @new_supplier
      invitation.accept!
      sign_in(@new_supplier.create_initial_user!)
      redirect_to dashboard_path
    else
      render 'new_supplier'
    end
  end

  def show
    @company = Company.find(params[:id])
    respond_with(@company)
  end
end
