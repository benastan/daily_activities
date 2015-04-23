require 'sinatra/base'
require 'interactor'
require 'faraday'
require 'psych'

module DailyActivities  
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
      list_id = (
        if lists.count == 0
          create_list = CreateList.call(
            list_title: 'Daily Activities List',
            user_id: current_user['id']
          )
          create_list.list_id
        else
          lists.first[:id]
        end
      )
      redirect to('/lists/%s' % list_id)
    end

    get '/lists/new' do
      @list = {}
      haml :new_list
    end

    get '/lists/:list_id' do
      list_id = params[:list_id]
      current_date = params[:date] ? Date.parse(params[:date]) : Date.today
      
      load_list = LoadListAndActivities.call(
        list_id: list_id,
        user_id: current_user['id'],
        date: current_date
      )

      @list = load_list.list
      @activity_name = nil
      @activities = load_list.activities
      @current_date = current_date
      @active_tab = 'record'
      haml :index
    end

    post '/lists' do
      list_attributes = params[:list]
      create_list = CreateList.call(
        list_title: list_attributes[:list_title],
        user_id: current_user['id']
      )
        
      unless create_list.success?
        @list = list_attributes
        @error = true
        @alert = create_list.message
        haml :new_list
      else
        session[:success] = 'List "%s" has been created!' % list_attributes[:list_title]
        list_id = create_list.list_id
        redirect to('/lists/%s' % list_id)
      end
    end

    get '/lists/:list_id/visualize' do
      context = { user_id: current_user['id'], list_id: params[:list_id] }
      context[:date] = params[:date] if params[:date]
      load_list_and_activities = LoadListAndActivities.call(context)

      @active_tab = 'visualize'
      @list = load_list_and_activities.list
      @data = ChartJS::PieChart.new(load_list_and_activities.activities)
      haml :data
    end

    get '/lists/:list_id/edit' do
      list_id = params[:list_id]
      load_list = LoadList.call(
        user_id: current_user['id'],
        list_id: list_id
      )
      @list = load_list.list
      @active_tab = 'edit'
      haml :edit_list
    end


    post '/lists/:list_id' do
      list_id = params[:list_id]
      list_title = params[:list][:list_title]
      update_list = ValidateAndUpdateList.call(
        user_id: current_user['id'],
        list_id: list_id,
        list_title: list_title
      )

      if update_list.success?
        session[:success] = 'List "%s" has been updated!' % list_title
        redirect to('/lists/%s' % list_id)
      else
        @list = update_list.list
        @error = true
        @alert = update_list.message
        @active_tab = 'edit'
        haml :edit_list
      end
    end

    delete '/lists/:list_id' do
      list_id = params[:list_id]
      list_title = params[:list][:list_title]
      safely_delete_list = SafelyDeleteList.call(
        user_id: current_user['id'],
        list_id: list_id,
        list_title: list_title
      )
      if safely_delete_list.success?
        session[:success] = 'List "%s" has been deleted.' % list_title
        redirect to('/')
      else
        @list = safely_delete_list.list
        @alert = safely_delete_list.message
        @active_tab = 'edit'
        haml :edit_list
      end
    end

    post '/lists/:list_id/activities' do
      activity_name = params[:activity][:activity_name]
      list_id = params[:list_id]
      record_date = params[:activity_record][:record_date]
      create_activity = CreateActivityAndActivityRecord.call(
        activity_name: activity_name,
        user_id: current_user['id'],
        record_date: record_date,
        list_id: list_id
      )
      
      if create_activity.success?
        redirect to('lists/%s?date=%s' % [list_id, record_date])
      else
        current_date = Date.today
        load_list_and_activities = LoadListAndActivities.call(
          list_id: list_id,
          user_id: current_user['id'],
          date: current_date
        )
        @list = load_list_and_activities.list
        @activity_name = activity_name
        @error = true
        @alert = create_activity.message
        @activities = load_list_and_activities.activities
        @current_date = current_date
        @active_tab = 'record'
        haml :index
      end
    end

    get '/activities/:activity_id/edit' do
      @activity = database[:activities][id: params[:activity_id]]
      haml :edit
    end

    post '/activities/:activity_id' do
      activity_name = params[:activity][:activity_name]
      activities = database[:activities].where(id: params[:activity_id])
      activities.update(activity_name: activity_name)
      redirect to('/')
    end

    post '/activities/:activity_id/records' do
      attributes = {
        activity_id: params[:activity_id],
        record_date: params[:activity_record][:record_date]
      }
      
      if params[:activity_record][:record] == 'true'
        attributes.merge(
          created_at: DateTime.now,
          updated_at: DateTime.now
        )
        CreateActivityRecord.call(attributes)
      else
        dataset = database[:activity_records].where(attributes)
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

      def lists
        database[:lists].where(user_id: current_user['id'])
      end

      def database
        Database.connection
      end
    end

    configure do
      use Rack::MethodOverride
      enable :sessions
      enable :logging
      file = File.new("#{settings.root}/../../log/#{settings.environment}.log", 'a+')
      file.sync = true
      use Rack::CommonLogger, file
    end
  end
end
