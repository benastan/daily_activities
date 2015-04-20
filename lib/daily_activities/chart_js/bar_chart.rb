module DailyActivities
  module ChartJS
    class BarChart < Hash
      def initialize(data)
        self[:labels] = [ 'Data' ]
        self[:datasets] = []
        data.each do |activity|
          color = ChartJS.generate_color
          self[:datasets] << {
            label: activity[:activity_name],
            data: [ activity[:record_count] ],
            strokeColor: color,
            highlightFill: color,
            highlightStroke: color,
            fillColor: color
          }
        end
      end
    end
  end
end
