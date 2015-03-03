Sequel.migration do
  up do
    create_table :activities do
      primary_key :id
      String :activity_name
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table :activities
  end
end