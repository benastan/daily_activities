require 'spec_helper'

module DailyActivities
  describe LoadActivityRecords do
    subject { LoadActivityRecords.call(record_date: Date.new(2014, 01, 01)) }
    let(:activity) { create_activity(activity_name: 'Go Running') }
    
    before do
      create_activity_record(activity: activity, record_date: Date.new(2014, 01, 01))
      create_activity_record(record_date: Date.new(2014, 01, 02))
    end

    it 'loads activity records for the given date' do
      expect(subject.activity_records).to match([
        hash_including(
          record_date: Date.new(2014, 01, 01),
          activity_name: 'Go Running',
          activity_id: activity[:id]
        )
      ])
    end
  end
end
