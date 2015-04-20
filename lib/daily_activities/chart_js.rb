module DailyActivities
  module ChartJS
    autoload :PieChart, 'daily_activities/chart_js/pie_chart'
    autoload :BarChart, 'daily_activities/chart_js/bar_chart'
    
    def self.generate_color
      colors = (0..9).to_a.concat(('A'..'F').to_a)
      hex = 6.times.map { |i| colors.sample }.join('')
      "##{hex}"
    end
  end
end
