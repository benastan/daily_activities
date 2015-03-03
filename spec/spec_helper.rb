ENV['RACK_ENV'] = 'test'
ENV['DATABASE_URL'] = ENV['TEST_DATABASE_URL']

require 'bundler'
Bundler.require
require 'daily_activities'
require 'capybara/webkit'
require 'capybara'
require 'database_cleaner'
require 'timecop'

Capybara.current_driver = :webkit
Capybara.app = DailyActivities::Application

database_cleaner = DatabaseCleaner[:sequel, {
  :connection => DailyActivities::Database.connection}
]

database_cleaner.clean_with(:truncation)

RSpec.configure do |config|
  config.around(:each) do |example|
    DatabaseCleaner.cleaning { example.run }
  end
end
