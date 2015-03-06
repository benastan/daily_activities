require 'spec_helper'

module DailyActivities
  describe LoadActivities do
    subject { LoadActivities.call(date: activity_record_date) }
    let!(:activity_id) { CreateActivity.call(activity_name: 'My Great Activity').activity_id }
    let(:activity) { Database.connection[:activities][id: activity_id] }

    before do
      CreateActivityRecord.call(record_date: Date.new(2014, 01, 02), activity_id: activity_id)
    end

    context 'when the activity does not have an activity record for the current day' do
      let(:activity_record_date) { Date.new(2014, 01, 01) }

      it 'loads all activities' do
        activity_with_activity_record = activity.merge(recorded: false)
        expect(subject.activities).to eq [ activity_with_activity_record ]
      end
    end

    context 'when the activity has an activity record for the current day' do
      let(:activity_record_date) { Date.new(2014, 01, 02) }

      it 'loads all activities' do
        activity_with_activity_record = activity.merge(recorded: true)
        expect(subject.activities).to eq [ activity_with_activity_record ]
      end
    end
  end
end
