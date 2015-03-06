module DailyActivities
  class CreateActivityRecord
    include Interactor

    def call
      activity_id = context[:activity_id]
      record_date = context[:record_date]

      context[:activity_record_id] = Database.connection[:activity_records].insert(
        activity_id: activity_id,
        record_date: record_date,
        created_at: DateTime.now,
        updated_at: DateTime.now
      )
    end
  end
end
