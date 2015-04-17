require 'spec_helper'

module DailyActivities
  describe LoadActivities do
    subject { LoadActivities.call(date: activity_record_date, user_id: '123123') }
    let!(:another_activity) { create_activity(activity_name: 'My Excellent Activity', user_id: '123123') }
    let!(:activity) { create_activity(activity_name: 'My Great Activity', user_id: '123123') }
    let!(:other_activity) { create_activity(activity_name: 'My Greater Activity', user_id: '123124') }
    let!(:activity_record) { create_activity_record(activity: activity) }
    let!(:earlier_activity_record) { create_activity_record(activity: activity, record_date: Date.new(2013, 12, 31)) }
    let!(:other_activity_record) { create_activity_record(activity: other_activity) }

    context 'when the activity does not have an activity record for the current day' do
      let(:activity_record_date) { Date.new(2014, 01, 01) }

      it 'loads all activities' do
        expect(subject.activities).to eq [
          activity.merge(recorded: false, record_count: 2),
          another_activity.merge(recorded: false, record_count: 0)
        ]
      end
    end

    context 'when the activity has an activity record for the current day' do
      let(:activity_record_date) { Date.new(2014, 01, 02) }

      it 'loads all activities' do
        expect(subject.activities).to eq [
          activity.merge(recorded: true, record_count: 2),
          another_activity.merge(recorded: false, record_count: 0)
        ]
      end
    end

    context 'when the activity was recorded for the current day, even if the other activity has more activities recorded' do
      let(:activity_record_date) { Date.new(2014, 01, 02) }

      before do
        create_activity_record(activity: another_activity, record_date: Date.new(2013, 12, 29))
        create_activity_record(activity: another_activity, record_date: Date.new(2013, 12, 30))
        create_activity_record(activity: another_activity, record_date: Date.new(2013, 12, 31))
      end

      it 'loads all activities' do
        expect(subject.activities).to eq [
          activity.merge(recorded: true, record_count: 2),
          another_activity.merge(recorded: false, record_count: 3)
        ]
      end
    end
  end
end
