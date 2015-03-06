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

database_cleaner = DatabaseCleaner[
  :sequel,
  { connection: DailyActivities::Database.connection }
]

module WaitForAjax
  def wait_for_ajax
    Timeout.timeout(Capybara.default_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
end

RSpec.configure do |config|
  config.include WaitForAjax, js: true

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
