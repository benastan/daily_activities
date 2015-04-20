module DailyActivities
  class CreateActivityAndActivityRecord
    include Interactor::Organizer

    organize [
      CreateActivity,
      CreateActivityRecord
    ]
  end
end
