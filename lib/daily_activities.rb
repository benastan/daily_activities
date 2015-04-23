require "daily_activities/version"

module DailyActivities
  autoload :Application, 'daily_activities/application'
  autoload :Database, 'daily_activities/database'
  autoload :CreateActivity, 'daily_activities/create_activity'
  autoload :CreateActivityRecord, 'daily_activities/create_activity_record'
  autoload :CreateActivityAndActivityRecord, 'daily_activities/create_activity_and_activity_record'
  autoload :CreateList, 'daily_activities/create_list'
  autoload :LoadActivities, 'daily_activities/load_activities'
  autoload :LoadActivityRecords, 'daily_activities/load_activity_records'
  autoload :LoadList, 'daily_activities/load_list'
  autoload :UpdateList, 'daily_activities/update_list'
  autoload :ValidateAndUpdateList, 'daily_activities/validate_and_update_list'
  autoload :ValidateList, 'daily_activities/validate_list'
  autoload :DeleteList, 'daily_activities/delete_list'
  autoload :SafelyDeleteList, 'daily_activities/safely_delete_list'
  autoload :ConfirmListTitle, 'daily_activities/confirm_list_title'
  autoload :LoadListAndActivities, 'daily_activities/load_list_and_activities'
  autoload :Google, 'daily_activities/google'
  autoload :SqlHelper, 'daily_activities/sql_helper'
  autoload :ChartJS, 'daily_activities/chart_js'
end
