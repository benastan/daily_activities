Sequel.migration do
  up do
    create_table :activity_records do
      primary_key :id
      Integer :activity_id
      Date :record_date
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table :activity_records
  end
end