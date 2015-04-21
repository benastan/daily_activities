module DailyActivities
  class LoadListAndActivities
    include Interactor::Organizer

    organize [
      LoadList,
      LoadActivities
    ]
  end
end
