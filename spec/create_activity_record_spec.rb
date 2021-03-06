require 'spec_helper'

module DailyActivities
  describe CreateActivityRecord do
    let!(:activity_id) { create_activity(activity_name: 'My Great Activity')[:id] }
    subject { CreateActivityRecord.call(context) }
    let(:created_activity_record) { Database.connection[:activity_records].all.last }#order(Sequel.asc(:created_at)).last }

    context 'when there is no activity id' do
      let(:context) { { record_date: Date.today } }

      it { is_expected.to_not be_success }

      it 'does not create an activity record' do
        expect { subject }.to_not change { Database.connection[:activity_records].count }
      end
    end

    context 'when there is an activity id' do
      let(:context) { { activity_id: activity_id, record_date: Date.today } }

      it { is_expected.to be_success }

      it 'creates an activity record' do
        expect { subject }.to change { Database.connection[:activity_records].count }.by(1)
      end

      it 'sets activity_id' do
        subject
        expect(created_activity_record[:activity_id]).to eq activity_id
      end

      it 'sets record_date' do
        subject
        expect(created_activity_record[:record_date]).to eq Date.today
      end

      it 'sets updated_at' do
        subject
        expect(created_activity_record[:updated_at]).to be_a Time
      end

      it 'sets created_at' do
        subject
        expect(created_activity_record[:created_at]).to be_a Time
      end

      it 'adds the id to the context' do
        expect(subject.activity_record_id).to eq created_activity_record[:id]
      end
    end
  end
end