module DailyActivities
  class LoadActivities
    include Interactor

    def call
      date = context[:date]
      user_id = context[:user_id]

      activities_star = Sequel.expr(:activities).*
      activity_records_id_is_not_null = Sequel.~(:activity_records__id => nil)
      context[:activities] = Database.
        connection[:activities].
        left_join(:activity_records, activity_id: :id, record_date: date.to_s).
        # left_outer_join(:activity_records, {activity_id: :id}, table_alias: :ar).
        where(user_id: user_id).
        select(
          activities_star,
          Sequel.as(activity_records_id_is_not_null, 'recorded'),
          Sequel.as(
            Database.
              connection[:activity_records].
              where(activity_id: :activities__id).
              select(Sequel.function(:count, :activity_records__id)),
            'record_count'
          )
        ).
        order(
          Sequel.desc(Sequel.lit('recorded')),
          Sequel.desc(Sequel.lit('record_count'))
        ).
        all
    end
  end
end
