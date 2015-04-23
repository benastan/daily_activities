module DailyActivities
  class ValidateList
    include Interactor

    def call
      user_id = context[:user_id]
      list_id = context[:list_id]
      list_title = context[:list_title]

      if list_title == ''
        context.fail!(message: 'Required fields are missing')
      end
    end
  end
end
