module MailerMacros
  def last_email
    ActionMailer::Base.cached_deliveries.last
  end
  
  def reset_email
    ActionMailer::Base.cached_deliveries = []
  end
end
