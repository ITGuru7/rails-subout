class Notifier < ActionMailer::Base
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::DateHelper

  default :from => "charterbusiness@suboutapp.com"
  layout 'mailer_default'

  before_filter :add_attachments

  def add_attachments
    attachments.inline['logo.png'] = File.read(Rails.root.join('app/assets/images/logo.png'))
  end

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

  def send_mail_to_company(template_name, company)
    send_mail_from_template(template_name, company.notifiable_email) if company.notifiable?
  end

  def send_mail_from_template(template_name, to, email_layout='mailer_default')
    if !Rails.env.production?
      mail(subject: template_name, to: to)
    else
      email_template = EmailTemplate.by_name(template_name)

      mail(subject: eval('"' + email_template.subject + '"', binding), to: to) do |format|
        format.html { render layout: email_layout, inline: eval('"' + email_template.body + '"', binding) }
      end
    end
  end

  def new_bid(bid_id)
    @bid = Bid.find(bid_id)
    return if @bid.is_canceled?

    @opportunity = @bid.opportunity
    @poster = @opportunity.buyer
    @bidder = @bid.bidder

    send_mail_to_company(__method__.to_s, @poster) 
  end

  def new_negotiation(bid_id)
    @bid = Bid.find(bid_id)
    return if @bid.is_canceled?
    
    @opportunity = @bid.opportunity
    @poster = @opportunity.buyer
    @bidder = @bid.bidder

    send_mail_to_company(__method__.to_s, @bidder) 
  end

  def counter_negotiation(bid_id)
    @bid = Bid.find(bid_id)
    return if @bid.is_canceled?

    @opportunity = @bid.opportunity
    @poster = @opportunity.buyer
    @bidder = @bid.bidder

    send_mail_to_company(__method__.to_s, @poster) 
  end

  def won_auction_to_buyer(opportunity_id)
    @opportunity = Opportunity.find(opportunity_id)
    @bid = @opportunity.winning_bid
    @poster = @opportunity.buyer
    @bidder = @bid.bidder

    send_mail_to_company(__method__.to_s, @poster)
  end

  def won_auction_to_supplier(opportunity_id)
    @opportunity = Opportunity.find(opportunity_id)
    @bid = @opportunity.winning_bid
    @poster = @opportunity.buyer
    @bidder = @bid.bidder

    send_mail_to_company(__method__.to_s, @bidder)
  end

  def finished_auction_to_bidder(opportunity_id, bidder_id)
    @opportunity = Opportunity.find(opportunity_id)
    @bidder = Company.find(bidder_id)

    send_mail_to_company(__method__.to_s, @bidder) if @bidder.notification_items.include?("opportunity-win")
  end

  def expired_auction_notification(auction_id)
    @opportunity = Opportunity.find(auction_id)
    @poster = @opportunity.buyer

    send_mail_to_company(__method__.to_s, @poster)
  end

  

  def completed_auction_notification_to_buyer(opportunity_id)
    @opportunity = Opportunity.find(opportunity_id)
    @bid = @opportunity.winning_bid
    @poster = @opportunity.buyer
    @bidder = @bid.bidder

    send_mail_to_company(__method__.to_s, @poster)
  end

  def completed_auction_notification_to_supplier(opportunity_id)
    @opportunity = Opportunity.find(opportunity_id)
    @bid = @opportunity.winning_bid
    @poster = @opportunity.buyer
    @bidder = @bid.bidder

    send_mail_to_company(__method__.to_s, @bidder)
  end

  def subscription_confirmation(subscription_id)
    @subscription = GatewaySubscription.find(subscription_id)

    send_mail_from_template(__method__.to_s, @subscription.email)
  end

  def new_opportunity(opportunity_id, company_id)
    @opportunity = Opportunity.find(opportunity_id)
    return if @opportunity.canceled?

    @company = Company.find(company_id)

    send_mail_to_company(__method__.to_s, @company)
  end

  def expired_card(company_id)
    @company = Company.find(company_id)
    @card_update_link = @company.chargify_service_url

    send_mail_to_company(__method__.to_s, @company)
  end

  def locked_company(company_id)
    @company = Company.find(company_id)

    send_mail_to_company(__method__.to_s, @company)
  end

  def updated_product(company_id)
    @company = Company.find(company_id)

    send_mail_to_company(__method__.to_s, @company)
  end

  def new_vehicle(vehicle_id)
    @vehicle = Vehicle.find(vehicle_id) 
    @company = @vehicle.company

    send_mail_from_template(__method__.to_s, Setting.admin_email)
  end

  def update_vehicle(vehicle_id, old_vehicle)
    @vehicle = Vehicle.find(vehicle_id) 
    @company = @vehicle.company
    @old_vehicle = old_vehicle

    send_mail_from_template(__method__.to_s, Setting.admin_email)
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

    send_mail_to_company(__method__.to_s, @company)
  end

  def new_quote_request(quote_request_id, company_id)
    @quote_request = QuoteRequest.find(quote_request_id)
    @company = Company.find(company_id)
    send_mail_to_company(__method__.to_s, @company)
  end

  def new_quote(quote_id)
    @quote = Quote.find(quote_id)
    @quote_request = @quote.quote_request
    @quoter = @quote.quoter

    send_mail_from_template(__method__.to_s, @quote_request.email, 'mailer_consumer')
  end

  def won_quote_to_consumer(quote_request_id)
    @quote_request = QuoteRequest.find(quote_request_id)
    @quote = @quote_request.winning_quote
    @quoter = @quote.quoter

    send_mail_from_template(__method__.to_s, @quote_request.email, 'mailer_consumer')
  end

  def won_quote_to_quoter(quote_request_id)
    @quote_request = QuoteRequest.find(quote_request_id)
    @quote = @quote_request.winning_quote
    @quoter = @quote.quoter

    send_mail_to_company(__method__.to_s, @quoter)
  end

  def expired_quote_request_notification(quote_request_id)
    @quote_request = QuoteRequest.find(quote_request_id)
    send_mail_from_template('expired_quote_request', @quote_request.email, 'mailer_consumer')
  end

  def invited_auction_to_vendor(bid_id)
    @bid = Bid.find(bid_id)
    @buyer = @opportunity.buyer
    @vendor = bid.vendor
    @opportunity = @bid.opportunity

    send_mail_from_template(__method__.to_s, @vendor.email, 'mailer_vendor')
  end

end
