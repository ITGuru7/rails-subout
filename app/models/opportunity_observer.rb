require "xmlrpc/client"

class OpportunityObserver < Mongoid::Observer
  observe :opportunity

  def after_create(opportunity)
    create_event(opportunity, :opportunity_created)
    send_notification_to_companies(opportunity)
  end

  def after_update(opportunity)
    if opportunity.canceled_changed?
      create_event(opportunity, :opportunity_canceled)
    elsif opportunity.winning_bid_id_changed?
      Event.create(actor_id: opportunity.winning_bid.bidder_id, action: {type: :opportunity_bidding_won}, eventable: opportunity)
    else
      create_event(opportunity, :opportunity_updated)
    end
  end

  private

  def create_event(opportunity, type)
    Event.create!(actor_id: opportunity.buyer_id, action: {type: type}, eventable: opportunity)
  end

  def send_notification_to_companies(opportunity)
    companies = Company.notified_recipients_by(opportunity)
    companies.each do |company|
      Notifier.delay_for(1.minutes).new_opportunity(opportunity.id, company.id)
      send_sms_notification(opportunity, company) if company.notification_type && company.cell_phone
    end
  end

  def send_sms_notification(opportunity, company)
    sms_url = ENV['SMS_URL'] || "api.smscloud.com"
    sms_path = ENV['SMS_PATH'] || "/xmlrpc?apiVersion=1.0&key=359B97E0832315A68655C73EB3323E52937CC401"

    number_bank = %w(12052674927 12055336910 12055336913 12055336915 12055336909)
    msg_bank = [
      "Subout : A new opportunity for you ",
      "Subout : A new entry just arrived ",
      "Subout : A new opportunity now available ",
      "Subout : Something new just showed up ",
      "Subout : A new opportunity is available for you ",
     
    ]


    begin
      bitly = Bitly.new("suboutdev", "R_8ba0587adb559eb9b2576826a915b557")
      short_url = bitly.shorten("#{ENV['EXTERNAL_URL']}/#/opportunities/#{opportunity.reference_number}").short_url        
    rescue Exception => e
      puts e.backtrace
      short_url = ""    
    end

    server = XMLRPC::Client.new(sms_url,sms_path)
    message = msg_bank.shuffle.first + "from #{opportunity.buyer.abbreviated_name}: #{opportunity.name} #{short_url}"

    begin
      server.call("sms.send", number_bank.shuffle.first, company.cell_phone, message, 1)
    rescue Exception => e
      puts e.backtrace
      puts e.inspect
    end
  end

end


