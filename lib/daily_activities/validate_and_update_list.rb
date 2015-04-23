module DailyActivities
  class ValidateAndUpdateList
    include Interactor::Organizer

    organize [
      LoadList,
      ValidateList,
      UpdateList
    ]
  end
end
