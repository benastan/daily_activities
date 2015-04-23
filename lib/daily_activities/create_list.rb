module DailyActivities
  class CreateList
    include Interactor

    def call
      list_title = context[:list_title]
      user_id = context[:user_id]      

      if list_title == ''
        context.fail!(message: 'Required fields are missing')
      end

      list_id = Database.connection[:lists].insert(
        list_title: list_title,
        user_id: user_id,
        created_at: DateTime.now,
        updated_at: DateTime.now
      )
      
      context[:list_id] = list_id
    end
  end
end
