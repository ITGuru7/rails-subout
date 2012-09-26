require 'cucumber/rails'
require 'email_spec/cucumber'
require 'sidekiq/testing'

Capybara.default_selector = :css
Capybara.javascript_driver = :webkit  
Capybara.default_wait_time = 5

ActionController::Base.allow_rescue = false

DatabaseCleaner.strategy = :truncation

Cucumber::Rails::Database.javascript_strategy = :truncation

#require 'headless'
#headless = Headless.new
#headless.start

