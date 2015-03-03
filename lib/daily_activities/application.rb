require 'sinatra/base'
require 'pry'

module DailyActivities
  class Application < Sinatra::Base
    get '/' do
      current_date_time = Date.today
      activity_records = Database.connection[:activity_records].where(record_date: current_date_time.to_s)
      activities = Database.connection[:activities].all.map do |activity|
        activity_record = activity_records.find do |activity_record|
          activity_record[:activity_id] == activity[:id]
        end

        activity[:recorded] = !!activity_record
        activity
      end

      haml :index, locals: { activities: activities, current_date_time: current_date_time }
    end

    post '/activities' do
      Database.connection[:activities].insert(
        activity_name: params[:activity][:activity_name],
        created_at: DateTime.now,
        updated_at: DateTime.now
      )

      redirect to('/')
    end

    post '/activities/:activity_id/records' do
      activity_id = params[:activity_id]
      record = params[:activity_record][:record] == 'true'
      record_date = params[:activity_record][:record_date]

      if record
        activity_record_attributes = {
          activity_id: activity_id,
          record_date: record_date,
          created_at: DateTime.now,
          updated_at: DateTime.now
        }

        Database.connection[:activity_records].insert(activity_record_attributes)
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
  end
end
