module SidekiqHelper
  def there_shoud_be_one_email
    Sidekiq::Extensions::DelayedMailer.jobs.size.should == 1
  end
end

World(SidekiqHelper)
