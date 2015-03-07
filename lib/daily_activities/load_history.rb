module DailyActivities
  class LoadHistory
    include Interactor

    def call
      context[:record_dates] = Database.connection['SELECT DISTINCT(record_date) FROM activity_records ORDER BY record_date DESC'].map { |record| record[:record_date] }
    end
  end
end
