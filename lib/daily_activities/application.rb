require 'sinatra/base'
require 'interactor'
require 'faraday'
require 'psych'

module DailyActivities
  autoload :CreateActivity, 'daily_activities/create_activity'
  autoload :CreateActivityRecord, 'daily_activities/create_activity_record'
  autoload :LoadActivities, 'daily_activities/load_activities'
  autoload :LoadActivityRecords, 'daily_activities/load_activity_records'
  autoload :Google, 'daily_activities/google'
  autoload :SqlHelper, 'daily_activities/sql_helper'
  autoload :ChartJS, 'daily_activities/chart_js'

  class Application < Sinatra::Base
    before do
      unless current_user || request.path == '/oauth/callback'
        state = SecureRandom.hex
        session[:auth_state] = state
        google = Google.new
        authorization_url = google.authorization_url(state: state)
        redirect to(authorization_url)
      end
    end

    get '/oauth/callback' do
      google = Google.new
      google.fetch_access_token(code: params['code'])
      session['user'] = google.me
      redirect to('/') 
    end

    get '/' do
      current_date = params[:date] ? Date.parse(params[:date]) : Date.today
      load_activities = LoadActivities.call(
        date: current_date,
        user_id: current_user['id']
      )

      haml :index, locals: {
        activity_name: nil,
        error: nil,
        activities: load_activities.activities,
        current_date: current_date
      }
    end

    get '/data' do
      context = { user_id: current_user['id'] }
      context[:date] = params[:date] if params[:date]
      load_activities = LoadActivities.call(context)

      haml :data, locals: {
        data: ChartJS::PieChart.new(load_activities.activities)
      }
    end

    post '/activities' do
      activity_name = params[:activity][:activity_name]
      create_activity = CreateActivity.call(
        activity_name: activity_name,
        user_id: current_user['id']
      )
      if create_activity.success?
        redirect to('/')
      else
        current_date = Date.today
        load_activities = LoadActivities.call(
          date: current_date,
          user_id: current_user['id']
        )
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

    set :public_folder, File.dirname(__FILE__) + '/static'

    helpers do
      def head(status)
        status status
        ''
      end

      def current_user
        if ENV['USER_YML']
          Psych.load(File.open(ENV['USER_YML']).read)
        else
          session[:user]
        end
      end
    end

    configure do
      enable :sessions
      enable :logging
      file = File.new("#{settings.root}/../../log/#{settings.environment}.log", 'a+')
      file.sync = true
      use Rack::CommonLogger, file
    end
  end
end
