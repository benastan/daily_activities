require 'sequel'

module DailyActivities
  module Database
    def self.connection
      @connection ||= (
        connection = Sequel.connect(ENV['DATABASE_URL'])
        connection.extension(:pg_array)
        connection
      )
    end
  end
end

Sequel.extension(:pg_array_ops)
