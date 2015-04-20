module DailyActivities
  class LoadActivities
    include Interactor
    include SqlHelper

    def call
      date = context[:date]
      user_id = context[:user_id]
      list_id = context[:list_id]

      where_options = { user_id: user_id }
      where_options[:list_id] = list_id if list_id

      query = Database.
        connection[:activities].
        where(where_options)

      query = GroupByActivityColumns.add_to(query)
      query = ActivityRecordJoin.add_to(query, date: date)

      select_fields = [
        star(:activities),
        Sequel.as(activity_activity_record_ids, 'activity_record_ids'),
        Sequel.as(activity_has_activity_records, 'recorded'),
        Sequel.as(activity_record_count, 'record_count')
      ]

      order_by_fields = [
        Sequel.asc(Sequel.lit('recorded')),
        Sequel.desc(Sequel.lit('record_count'))
      ]

      query = query.
        select(*select_fields).
        order(*order_by_fields)

      context[:activities] = query.all
    end
  end
end
