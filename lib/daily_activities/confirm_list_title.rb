module DailyActivities
  class ConfirmListTitle
    include Interactor
    
    def call
      list_title = context[:list_title]
      list = context[:list]
      correct_list_title = list[:list_title]
      
      unless list_title == correct_list_title
        context.fail!(message: 'Please confirm the name of the list you are deleting.')
      end
    end
  end
end
