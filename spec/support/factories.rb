module DailyActivities
  module Factories
    def create_activity(activity_name: 'Activity Name')
      create_activity = CreateActivity.call(activity_name: activity_name)
      Database.connection[:activities][id: create_activity.activity_id]
    end

    def create_activity_record(record_date: Date.new(2014, 01, 02), activity: create_activity)
      create_activity_record = CreateActivityRecord.call(record_date: record_date, activity_id: activity[:id])
      Database.connection[:activity_records][id: create_activity_record.activity_record_id]
    end
  end
end
