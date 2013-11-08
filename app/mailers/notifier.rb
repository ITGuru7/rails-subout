class Notifier < ActionMailer::Base
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::DateHelper

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

  def send_mail_from_template(template_name, to)
    email_template = EmailTemplate.by_name(template_name)
    mail(subject: eval('"' + email_template.subject + '"', binding), to: to) do |format|
      format.html { render inline: eval('"' + email_template.body_with_signature + '"', binding) }
    end
  end

  def new_bid(bid_id)
    if @bid = Bid.active.where(id: bid_id).first
      @opportunity = @bid.opportunity
      @poster = @opportunity.buyer
      @bidder = @bid.bidder

      send_mail_from_template(__method__.to_s, @poster.notifiable_email)
    end
  end

  def won_auction_to_buyer(opportunity_id)
    @opportunity = Opportunity.find(opportunity_id)
    @bid = @opportunity.winning_bid
    @poster = @opportunity.buyer
    @bidder = @bid.bidder

    send_mail_from_template(__method__.to_s, @poster.notifiable_email)
  end

  def won_auction_to_supplier(opportunity_id)
    @opportunity = Opportunity.find(opportunity_id)
    @bid = @opportunity.winning_bid
    @poster = @opportunity.buyer
    @bidder = @bid.bidder

    send_mail_from_template(__method__.to_s, @bidder.notifiable_email)
  end

  def finished_auction_to_bidder(opportunity_id, bidder_id)
    @opportunity = Opportunity.find(opportunity_id)
    @bidder = Company.find(bidder_id)

    send_mail_from_template(__method__.to_s, @bidder.notifiable_email) if @bidder.notification_items.include?("opportunity-win")
  end

  def expired_auction_notification(auction_id)
    @opportunity = Opportunity.find(auction_id)
    @poster = @opportunity.buyer

    send_mail_from_template(__method__.to_s, @poster.notifiable_email)
  end

  def completed_auction_notification_to_buyer(opportunity_id)
    @opportunity = Opportunity.find(opportunity_id)
    @bid = @opportunity.winning_bid
    @poster = @opportunity.buyer
    @bidder = @bid.bidder

    send_mail_from_template(__method__.to_s, @poster.notifiable_email)
  end

  def completed_auction_notification_to_supplier(opportunity_id)
    @opportunity = Opportunity.find(opportunity_id)
    @bid = @opportunity.winning_bid
    @poster = @opportunity.buyer
    @bidder = @bid.bidder

    send_mail_from_template(__method__.to_s, @bidder.notifiable_email)
  end

  def subscription_confirmation(subscription_id)
    @subscription = GatewaySubscription.find(subscription_id)

    send_mail_from_template(__method__.to_s, @subscription.email)
  end

  def new_opportunity(opportunity_id, company_id)
    @opportunity = Opportunity.find(opportunity_id)
    return if @opportunity.canceled?

    @company = Company.find(company_id)

    send_mail_from_template(__method__.to_s, @company.notifiable_email)
  end

  def expired_card(company_id)
    @company = Company.find(company_id)
    @card_update_link = @company.chargify_service_url

    send_mail_from_template(__method__.to_s, @company.notifiable_email)
  end

  def locked_company(company_id)
    @company = Company.find(company_id)

    send_mail_from_template(__method__.to_s, @company.notifiable_email)
  end

  def updated_product(company_id)
    @company = Company.find(company_id)

    send_mail_from_template(__method__.to_s, @company.notifiable_email)
  end

  def new_vehicle(vehicle_id)
    if @vehicle = Vehicle.find(vehicle_id) 
      @company = @vehicle.company

      send_mail_from_template(__method__.to_s, Setting.admin_email)
    end
  end

  def update_vehicle(vehicle_id, old_vehicle)
    if @vehicle = Vehicle.find(vehicle_id) 
      @company = @vehicle.company
      @old_vehicle = old_vehicle

      send_mail_from_template(__method__.to_s, Setting.admin_email)
    end
  end

  def remove_vehicle(vehicle)
    @vehicle = vehicle
    @company = Company.find(vehicle.company_id) 

    send_mail_from_template(__method__.to_s, Setting.admin_email)
  end

  def remind_registration_to_user(subscription_id)
    @subscription = GatewaySubscription.find(subscription_id)

    send_mail_from_template(__method__.to_s, @subscription.email)
  end

  def remind_registration_to_admin(subscription_id)
    @subscription = GatewaySubscription.find(subscription_id)

    send_mail_from_template(__method__.to_s, Setting.admin_email)
  end

  def daily_reminder(company_id)
    @company = Company.find(company_id)

    send_mail_from_template(__method__.to_s, @company.notifiable_email)
  end
end
