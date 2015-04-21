module DailyActivities
  class LoadList
    include Interactor

    def call
      list_id = context[:list_id]
      user_id = context[:user_id]

      list = Database.connection[:lists][id: list_id, user_id: user_id] 

      context[:list] = list
    end
  end
end
