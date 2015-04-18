module DailyActivities
  module SqlHelper
    def array_length(*args)
      Sequel.function(:array_length, *args)
    end

    def array_agg(*args)
      Sequel.function(:array_agg, *args)
    end

    def array_remove(*args)
      Sequel.function(:array_remove, *args)
    end

    def arrays_overlap(array, other_array)
      Sequel.pg_array_op(array).overlaps(other_array)
    end

    def array_join(array, str)
      Sequel.pg_array_op(array).join(str)
    end

    def pg_array(array)
      Sequel.pg_array(array)
    end

    def is_not(arg)
      Sequel.~(arg)
    end

    def star(table_name)
      Sequel.expr(table_name).*
    end

    def activity_activity_record_ids
      array_remove(array_agg(:activity_records__id), nil)
    end

    def activity_has_activity_records
      is_not(array_length(activity_activity_record_ids, 1) => 0)
    end

    def activity_record_count
      Database.
        connection[:activity_records].
        where(activity_id: :activities__id).
        select(Sequel.function(:count, :activity_records__id))
    end

    module ActivityRecordJoin
      def self.options(date: nil)
        options = { activity_id: :id }
        options[:record_date] = date.to_s unless date.nil?
        options
      end

      def self.add_to(query, date: nil)
        query.left_join(:activity_records, options(date: date))
      end
    end

    module GroupByActivityColumns
      def self.options
        [
          :activities__id,
          :activities__activity_name,
          :activities__created_at,
          :activities__updated_at,
          :activities__user_id
        ]
      end

      def self.add_to(query)
        query.group_by(*options)
      end
    end
  end
end
