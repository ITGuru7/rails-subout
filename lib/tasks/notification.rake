namespace :subout do
  task :send_expired_notification => :environment do
    Opportunity.send_expired_notification
  end

  task :send_completed_notification => :environment do
    Opportunity.send_completed_notification
  end

  task :fix_bidding_ends_at => :environment do
    Opportunity.where(bidding_ends_at: nil).each do |opportunity|
      opportunity.send(:set_bidding_ends_at)
      opportunity.save(validate: false)
    end
  end

  task :fix_broken_chargify => :environment do
    Company.each do |company|
      email = company.email
      subscriptions = GatewaySubscription.where(email: email)
      while subscriptions.count > 1
        subscriptions.first.destroy 
        subscriptions = GatewaySubscription.where(email: email)
      end
      s = subscriptions.first
      s.set_regions
      s.save
      company.created_from_subscription_id = s._id
      company.set_subscription_info
      company.save
    end
  end
end
