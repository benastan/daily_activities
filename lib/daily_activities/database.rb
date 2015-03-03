require 'sequel'

module DailyActivities
  module Database
    def self.connection
      @connection = Sequel.connect(ENV['DATABASE_URL'])
    end
  end
end
