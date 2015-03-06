require 'sinatra/base'
require 'interactor'
require 'daily_activities/create_activity'
require 'daily_activities/create_activity_record'
require 'daily_activities/load_activities'

module DailyActivities
  class Application < Sinatra::Base
    get '/' do
      current_date = Date.today
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
