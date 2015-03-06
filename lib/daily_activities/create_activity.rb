module DailyActivities
  class CreateActivity
    include Interactor

    def call
      activity_name = context[:activity_name] || ''
      
      if activity_name != ''
        result = Database.connection[:activities].insert(
          activity_name: activity_name,
          created_at: DateTime.now,
          updated_at: DateTime.now
        )

        context[:activity_id] = result
      else
        context.fail!(message: 'Activity name is blank.')
      end
    end
  end
end
