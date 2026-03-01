source "https://rubygems.org"

ruby "3.2.9"
gem "rails", "~> 7.1.5", ">= 7.1.5.1"
gem "sprockets-rails"
gem "sqlite3", ">= 1.4"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false
gem 'bootstrap', '~> 5.3.0'
gem 'sassc-rails'
gem 'active_storage_validations'
gem 'rack-cors'
gem 'httparty'
gem "aws-sdk-s3", require: false
gem 'image_processing', '~> 1.2'
gem 'kaminari'
gem 'bootstrap5-kaminari-views'
gem 'devise'
gem 'sidekiq'
gem 'sidekiq-cron'
gem 'dotenv-rails', groups: [:development, :test]

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

group :production do
  gem 'pg'
end
