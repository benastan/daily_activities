module DailyActivities
  class SafelyDeleteList
    include Interactor::Organizer

    organize [
      LoadList,
      ConfirmListTitle,
      DeleteList
    ]
  end
end