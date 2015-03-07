module DailyActivities
  class LoadActivityRecords
    include Interactor

    def call
      record_date = context[:record_date]
      context[:activity_records] = Database.
        connection[:activity_records].
        where(record_date: record_date).
        join_table(:inner, :activities, id: :activity_id).
        all
    end
  end
end
