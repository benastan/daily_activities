require 'spec_helper'

module DailyActivities
  describe LoadHistory do
    subject { DailyActivities::LoadHistory.call }
    
    before do
      create_activity_record(record_date: Date.new(2014, 01, 02))
      create_activity_record(record_date: Date.new(2014, 01, 01))
    end

    it 'loads a list of dates for activity records' do
      expect(subject.record_dates).to eq [ Date.new(2014, 01, 02), Date.new(2014, 01, 01) ]
    end
  end
end
