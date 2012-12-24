namespace :subout do
  task :send_expired_notification => :environment do
    Opportunity.send_expired_notification
  end

  task :fix_bidding_ends_at => :environment do
    Opportunity.where(bidding_ends_at: nil).each do |opportunity|
      opportunity.send(:set_bidding_ends_at)
      opportunity.save(validate: false)
    end
  end
end
