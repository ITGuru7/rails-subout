class Notifier < ActionMailer::Base
  default :from => "noreply@suboutapp.com"

  def send_known_favorite_invitation(buyer_id, supplier_id)
    @buyer = Company.find(buyer_id)
    @supplier = Company.find(supplier_id)

    mail(subject: "[SubOut] Favorite Invitation from #{@buyer.name}", to: @supplier.notifiable_email)
  end

  def send_unknown_favorite_invitation(invitation_id)
    invitation = FavoriteInvitation.find(invitation_id)
    @buyer = invitation.buyer
    @invitation = invitation
    mail(subject: "[SubOut] New Favorite Guest Supplier Invitation from #{@buyer.name}", to: invitation.supplier_email)
  end

  def new_bid(bid_id)
    if @bid = Bid.active.where(id: bid_id).first
      @opportunity = @bid.opportunity
      @buyer = @opportunity.buyer
      @bidder = @bid.bidder

      mail(subject: "[SubOut] New bid on: #{@opportunity.name}", to: @buyer.notifiable_email)
    end
  end

  def won_auction_to_buyer(opportunity_id)
    @auction = Opportunity.find(opportunity_id)
    @bid = @auction.winning_bid
    @poster = @auction.buyer
    @bidder = @bid.bidder

    mail(subject: "[SubOut] #{@bid.bidder.name} has won the bidding on #{@auction.name}", to: @poster.notifiable_email)
  end

  def won_auction_to_supplier(opportunity_id)
    @auction = Opportunity.find(opportunity_id)
    @bid = @auction.winning_bid
    @buyer = @auction.buyer
    @bidder = @bid.bidder
    mail(subject: "[SubOut] You won the bidding on #{@auction.name}", to: @bidder.notifiable_email)
  end

  def finished_auction_to_bidder(opportunity_id, bidder_id)
    @auction = Opportunity.find(opportunity_id)
    @bidder = Company.find(bidder_id)
    mail(subject: "[SubOut] You didn't win the bidding on #{@auction.name}.", to: @bidder.notifiable_email) if @bidder.notification_items.include?("opportunity-win")
  end

  def expired_auction_notification(auction_id)
    @auction = Opportunity.find(auction_id)
    @poster = @auction.buyer
    mail(subject: "[SubOut] Your auction #{@auction.name} is expired", to: @poster.notifiable_email)
  end

  def completed_auction_notification_to_buyer(opportunity_id)
    @auction = Opportunity.find(opportunity_id)
    @bid = @auction.winning_bid
    @poster = @auction.buyer
    @bidder = @bid.bidder

    mail(subject: "[SubOut] Your auction #{@auction.name} is completed", to: @poster.notifiable_email)
  end

  def completed_auction_notification_to_supplier(opportunity_id)
    @auction = Opportunity.find(opportunity_id)
    @bid = @auction.winning_bid
    @poster = @auction.buyer
    @bidder = @bid.bidder

    mail(subject: "[SubOut] Your auction #{@auction.name} is completed", to: @bidder.notifiable_email)
  end

  def subscription_confirmation(subscription_id)
    @subscription = GatewaySubscription.find(subscription_id)

    mail(subject: "[SubOut] confirm your subscription", to: @subscription.email)
  end

  def new_opportunity(opportunity_id, company_id)
    @opportunity = Opportunity.find(opportunity_id)
    return if @opportunity.canceled?

    @company = Company.find(company_id)
    mail(subject: "[SubOut] new opportunity arrived", to: @company.notifiable_email)
  end

  def expired_card(company_id)
    @company = Company.find(company_id)
    @card_update_link = @company.chargify_service_url
    mail(subject: "[SubOut] Credit card is expired", to: @company.notifiable_email)
  end

  def locked_company(company_id)
    @company = Company.find(company_id)
    mail(subject: "[SubOut] Your company is locked", to: @company.notifiable_email)
  end

  def updated_product(company_id)
    @company = Company.find(company_id)
    mail(subject: "[SubOut] updated subscription product", to: @company.notifiable_email)
  end

  def new_vehicle(vehicle_id)
    if @vehicle = Vehicle.find(vehicle_id) 
      @company = @vehicle.company

      mail(subject: "[SubOut] New vehicle on: #{@company.name}", to: Setting.admin_email)
    end
  end

  def update_vehicle(vehicle_id, old_vehicle)
    if @vehicle = Vehicle.find(vehicle_id) 
      @company = @vehicle.company
      @old_vehicle = old_vehicle

      mail(subject: "[SubOut] Vehicle is updated on: #{@company.name}", to: Setting.admin_email)
    end
  end

  def remove_vehicle(vehicle)
    @vehicle = vehicle
    @company = Company.find(vehicle.company_id) 

    mail(subject: "[SubOut] Vehicle is removed on: #{@company.name}", to: Setting.admin_email)
  end

  def remind_to_user(user_id)
    @user = User.find(user_id)
    @company = @user.company

    mail(subject: "[SubOut] You didn't login in last 3 days", to: @user.email)
  end

  def remind_to_admin(user_id)
    @user = User.find(user_id)
    @company = @user.company

    mail(subject: "[SubOut] #{@company.name} didn't login in last 3 days", to: 'sales@subout.com')
  end
end
