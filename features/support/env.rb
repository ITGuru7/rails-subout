#require 'rspec'
require 'cucumber/rails'
require 'email_spec/cucumber'
require 'sidekiq/testing/inline'
require 'database_cleaner/cucumber'

#require 'capybara-screenshot/cucumber'
#require 'capybara/poltergeist'
#Capybara.javascript_driver = :poltergeist

#Capybara.app_host = 'http://localhost:3333/'
#Capybara.server_port = 3001

#Capybara.register_driver :chrome do |app|
  #Capybara::Selenium::Driver.new(app, :browser => :chrome)
#end

#Capybara.javascript_driver = :chrome

Capybara.default_selector = :css
#Capybara.javascript_driver = :webkit  
Capybara.default_wait_time = 5

ActionController::Base.allow_rescue = false

DatabaseCleaner.strategy = :truncation


Before do
  DatabaseCleaner.clean
  DatabaseCleaner.start
end

After do 
  DatabaseCleaner.clean
end

Cucumber::Rails::Database.javascript_strategy = :truncation

#require 'headless'
#headless = Headless.new
#headless.start

