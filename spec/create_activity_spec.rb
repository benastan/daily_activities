require 'spec_helper'

module DailyActivities
  describe CreateActivity do
    subject { CreateActivity.call(activity_name: activity_name, user_id: user_id) }
    let(:activity_name) { 'My Great Activity' }
    let(:user_id) { '123123' }
    let(:created_activity) { Database.connection[:activities].order(Sequel.asc(:created_at)).last }

    context 'when the record is valid' do
      it { is_expected.to be_success }

      it 'creates an activity' do
        expect { subject }.to change { Database.connection[:activities].count }.by(1)
      end

      it %q(sets the activity's created at date) do
        subject
        expect(created_activity[:created_at]).to be_a Time
      end

      it %q(sets the activity's updated at date) do
        subject
        expect(created_activity[:updated_at]).to be_a Time
      end

      it %q(sets the activity's user_id date) do
        subject
        expect(created_activity[:user_id]).to eq '123123'
      end

      it %q(include the activity's id in the context) do
        expect(subject[:activity_id]).to eq created_activity[:id]
      end
    end

    context 'when activity_name is missing' do
      let(:activity_name) { nil }
      it { is_expected.to_not be_success }

      it 'does not create activity' do
        expect { subject }.to_not change { Database.connection[:activities].count }
      end

      it 'provides a message' do
        expect(subject.message).to eq 'Required fields are missing'
      end
    end

    context 'when user_id is missing' do
      let(:user_id) { nil }
      it { is_expected.to_not be_success }

      it 'does not create activity' do
        expect { subject }.to_not change { Database.connection[:activities].count }
      end

      it 'provides a message' do
        expect(subject.message).to eq 'Required fields are missing'
      end
    end
  end
end
