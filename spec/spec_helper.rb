ENV['RACK_ENV'] = 'test'
ENV['DATABASE_URL'] = ENV['TEST_DATABASE_URL']

require 'bundler'
Bundler.require
require 'daily_activities'
require 'capybara/webkit'
require 'capybara'
require 'database_cleaner'
require 'timecop'
require 'pry'
require 'awesome_print'

Capybara.current_driver = :webkit
Capybara.app = DailyActivities::Application

database_cleaner = DatabaseCleaner[
  :sequel,
  { connection: DailyActivities::Database.connection }
]

autoload :WaitForAjax, './spec/support/wait_for_ajax'

module DailyActivities
  autoload :Factories, './spec/support/factories'
end

RSpec.configure do |config|
  config.include WaitForAjax, js: true
  config.include DailyActivities::Factories

  config.before(:suite) do
    database_cleaner.clean_with(:truncation)
  end

  config.before(:each) do
    database_cleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    database_cleaner.strategy = :truncation
  end

  config.before(:each) do
    database_cleaner.start
  end

  config.after(:each) do
    database_cleaner.clean
  end
end
