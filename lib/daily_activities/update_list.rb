module DailyActivities
  class UpdateList
    include Interactor

    def call
      user_id = context[:user_id]
      list_id = context[:list_id]
      list_title = context[:list_title]

      lists = Database.connection[:lists].where(
        user_id: user_id,
        id: list_id
      )

      lists.update(
        list_title: list_title,
        updated_at: DateTime.now
      )
    end
  end
end
