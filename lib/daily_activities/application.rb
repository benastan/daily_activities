require 'sinatra/base'
require 'interactor'


module DailyActivities
  autoload :CreateActivity, 'daily_activities/create_activity'
  autoload :CreateActivityRecord, 'daily_activities/create_activity_record'
  autoload :LoadActivities, 'daily_activities/load_activities'
  autoload :LoadHistory, 'daily_activities/load_history'
  autoload :LoadActivityRecords, 'daily_activities/load_activity_records'

  class Application < Sinatra::Base
    get '/' do
      current_date = params[:date] ? Date.parse(params[:date]) : Date.today
      load_activities = LoadActivities.call(date: current_date)
      haml :index, locals: {
        activity_name: nil,
        error: nil,
        activities: load_activities.activities,
        current_date: current_date
      }
    end

    post '/activities' do
      activity_name = params[:activity][:activity_name]
      create_activity = CreateActivity.call(activity_name: activity_name)
      if create_activity.success?
        redirect to('/')
      else
        current_date = Date.today
        load_activities = LoadActivities.call(date: current_date)
        haml :index, locals: {
          activity_name: activity_name,
          error: create_activity.message,
          activities: load_activities.activities,
          current_date: current_date
        }
      end
    end

    get '/activities' do
      date = params[:date]
      load_activity_records = LoadActivityRecords.call(record_date: date)
      haml :activities, locals: {
        date: date,
        activity_records: load_activity_records.activity_records
      }
    end

    get '/activities/:activity_id/edit' do
      activity = Database.connection[:activities][id: params[:activity_id]]
      haml :edit, locals: { activity: activity, error: nil }
    end

    post '/activities/:activity_id' do
      Database.connection[:activities].where(id: params[:activity_id]).update(
        activity_name: params[:activity][:activity_name]
      )

      redirect to('/')
    end

    post '/activities/:activity_id/records' do
      activity_id = params[:activity_id]
      record = params[:activity_record][:record] == 'true'
      record_date = params[:activity_record][:record_date]

      if record
        CreateActivityRecord.call(
          activity_id: activity_id,
          record_date: record_date,
          created_at: DateTime.now,
          updated_at: DateTime.now
        )
      else
        dataset = Database.connection[:activity_records].where(
          record_date: record_date,
          activity_id: activity_id
        )

        dataset.delete
      end

      head 200
    end

    get '/history' do
      load_history = LoadHistory.call
      haml :history, locals: { record_dates: load_history.record_dates }
    end

    set :public_folder, File.dirname(__FILE__) + '/static'

    helpers do
      def head(status)
        status status
        ''
      end
    end

    configure do
      enable :logging
      file = File.new("#{settings.root}/../../log/#{settings.environment}.log", 'a+')
      file.sync = true
      use Rack::CommonLogger, file
    end
  end
end
