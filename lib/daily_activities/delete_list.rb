module DailyActivities
  class DeleteList
    include Interactor

    def call
      user_id = context[:user_id]
      list_id = context[:list_id]

      lists = Database.connection[:lists].where(
        user_id: user_id,
        id: list_id
      )
      lists.delete
    end
  end
end
