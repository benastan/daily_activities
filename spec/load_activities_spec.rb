require 'spec_helper'

module DailyActivities
  describe LoadActivities do
    let(:context) do
      {date: activity_record_date, user_id: 'user' }
    end

    subject { LoadActivities.call(context) }
    let!(:another_activity) { create_activity(activity_name: 'Another Activity', user_id: 'user', list_id: 2) }
    let!(:activity) { create_activity(activity_name: 'Activity', user_id: 'user', list_id: 1) }
    let!(:other_activity) { create_activity(activity_name: 'Other Activity', user_id: 'user', list_id: 1) }
    let!(:other_user_activity) { create_activity(activity_name: 'Other User Activity', user_id: 'other user', list_id: 2) }
    
    before do
      create_activity_record(activity: activity, record_date: Date.new(2014, 01, 05))
      create_activity_record(activity: activity, record_date: Date.new(2013, 12, 31))
      create_activity_record(activity: other_activity, record_date: Date.new(2014, 01, 02))
      create_activity_record(activity: other_user_activity)
    end
    
    shared_examples_for 'order of :attribute is :list' do |attribute, list|
      specify do
        expect(subject.activities.map{|activity| activity[attribute]}).to eq list
      end
    end

    context 'when list_id has been supplied' do
      before { context[:list_id] = 1 }
      let(:activity_record_date) { Date.new(2014, 01, 01) }

      it_should_behave_like 'order of :attribute is :list', :activity_name, ['Activity', 'Other Activity']
      it_should_behave_like 'order of :attribute is :list', :record_count, [2, 1]
      it_should_behave_like 'order of :attribute is :list', :recorded, [nil, nil]
      
      it 'orders "Activity" first, with the most activity records' do
        expect(subject.activities[0]).to match hash_including(
          activity_name: 'Activity',
          id: activity[:id],
          record_count: 2,
          recorded: nil
        )
      end

      it 'orders "Other Activity" last, with the seconds most activity records' do
        expect(subject.activities[1]).to match hash_including(
          activity_name: 'Other Activity',
          id: other_activity[:id],
          record_count: 1,
          recorded: nil
        )
      end
    end

    context 'when no date has been supplied' do
      before { context.delete(:date) }
      let(:activity_record_date) { Date.new(2014, 01, 01) }

      it_should_behave_like 'order of :attribute is :list', :activity_name, ['Activity', 'Other Activity', 'Another Activity']
      it_should_behave_like 'order of :attribute is :list', :record_count, [2, 1, 0 ]
      it_should_behave_like 'order of :attribute is :list', :recorded, [true, true, nil]
      
      it 'orders "Activity" first, with the most activity records' do
        expect(subject.activities[0]).to match hash_including(
          activity_name: 'Activity',
          id: activity[:id],
          record_count: 2,
          recorded: true
        )
      end

      it 'orders "Other Activity" second, with the seconds most activity records' do
        expect(subject.activities[1]).to match hash_including(
          activity_name: 'Other Activity',
          id: other_activity[:id],
          record_count: 1,
          recorded: true
        )
      end
      
      it 'orders "Another Activity" last, with the fewest activity records' do
        expect(subject.activities[2]).to match hash_including(
          activity_name: 'Another Activity',
          id: another_activity[:id],
          record_count: 0,
          recorded: nil
        )
      end
    end

    context 'when a date is provided, but no activity records exist for the date' do
      let(:activity_record_date) { Date.new(2014, 01, 01) }

      it_should_behave_like 'order of :attribute is :list', :activity_name, [
        'Activity',
        'Other Activity',
        'Another Activity'
      ]
      
      it 'orders "Activity" first, with the most activity records' do
        expect(subject.activities[0]).to match hash_including(
          record_count: 2,
          activity_name: 'Activity',
          id: activity[:id],
          recorded: nil
        )
      end

      it 'orders "Other Activity" second, with the seconds most activity records' do
        expect(subject.activities[1]).to match hash_including(
          record_count: 1,
          activity_name: 'Other Activity',
          id: other_activity[:id],
          recorded: nil
        )
      end
      
      it 'orders "Another Activity" last, with the fewest activity records' do
        expect(subject.activities[2]).to match hash_including(
          record_count: 0,
          activity_name: 'Another Activity',
          id: another_activity[:id],
          recorded: nil
        )
      end
    end

    context 'when a date is provided, and activity records exist for the date' do
      let(:activity_record_date) { Date.new(2014, 01, 02) }

      it_should_behave_like 'order of :attribute is :list', :activity_name, [
        'Other Activity',
        'Activity',
        'Another Activity'
      ]

      it 'orders "Other Activity" first, because it was recorded for the date' do
        expect(subject.activities[0]).to match hash_including(
          record_count: 1,
          activity_name: 'Other Activity',
          id: other_activity[:id],
          recorded: true
        )
      end
      
      
      it 'orders "Activity" second, with the most activity records' do
        expect(subject.activities[1]).to match hash_including(
          record_count: 2,
          activity_name: 'Activity',
          id: activity[:id],
          recorded: nil
        )
      end

      it 'orders "Another Activity" last, with the fewest activity records' do
        expect(subject.activities[2]).to match hash_including(
          record_count: 0,
          activity_name: 'Another Activity',
          id: another_activity[:id],
          recorded: nil
        )
      end
    end
  end
end
