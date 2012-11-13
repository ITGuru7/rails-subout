source 'https://rubygems.org'

ruby '1.9.3'
gem 'rails', '3.2.3'

gem "mongoid", "~> 3.0.0.rc"
gem 'haml-rails'
gem 'jquery-rails'
gem 'pusher'
gem 'thin'
gem "devise"
gem 'simple_form'
gem 'sidekiq'
gem 'sinatra', :require => nil
gem 'slim'
gem 'rails_admin'
gem 'mongoid_rails_migrations'
gem 'rack-cors', :require => 'rack/cors'
gem 'kiqstand'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem "therubyracer"
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

group :development, :test do
  gem "pry"
  gem "factory_girl_rails", "~> 4.0"
  gem 'ffaker'
  gem 'heroku'
end

group :test do
  gem "rspec-rails"
  gem "cucumber-rails", :require => false
  gem "database_cleaner"
  #gem "capybara-webkit"
  #gem 'poltergeist'
  gem 'fivemat'
  gem 'email_spec'
  #gem 'capybara-screenshot'
end
