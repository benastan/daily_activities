module DailyActivities
  class CreateActivity
    include Interactor

    def call
      activity_name = context[:activity_name] || ''
      user_id = context[:user_id]
      list_id = context[:list_id]
      
      if activity_name != '' && !user_id.nil? && !list_id.nil?
        result = Database.connection[:activities].insert(
          activity_name: activity_name,
          user_id: user_id,
          list_id: list_id,
          created_at: DateTime.now,
          updated_at: DateTime.now
        )

        context[:activity_id] = result
      else
        context.fail!(message: 'Required fields are missing')
      end
    end
  end
end
