module DailyActivities
  class LoadActivities
    include Interactor

    def call
      date = context[:date]
      activity_records = Database.connection[:activity_records].where(record_date: date.to_s)
      context[:activities] = Database.connection[:activities].all.map do |activity|
        activity_record = activity_records.find do |activity_record|
          activity_record[:activity_id] == activity[:id]
        end

        activity[:recorded] = !!activity_record
        activity
      end
    end
  end
end
