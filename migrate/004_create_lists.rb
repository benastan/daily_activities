Sequel.migration do
  up do
    create_table :lists do
      primary_key :id
      String :list_title
      String :user_id
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table :lists
  end
end