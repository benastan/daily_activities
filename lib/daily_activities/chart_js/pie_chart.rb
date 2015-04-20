module DailyActivities
  module ChartJS
    class PieChart < Array
      def initialize(data)
        data.each do |activity|
          point = {
            label: activity[:activity_name],
            value: activity[:record_count],
            color: ChartJS.generate_color
          }
          self << point
        end
      end
    end
  end
end
