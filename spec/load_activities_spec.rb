require 'spec_helper'

module DailyActivities
  describe LoadActivities do
    subject { LoadActivities.call(date: activity_record_date) }
    let!(:activity) { create_activity(activity_name: 'My Great Activity') }
    let!(:activity_record) { create_activity_record(activity: activity) }

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
