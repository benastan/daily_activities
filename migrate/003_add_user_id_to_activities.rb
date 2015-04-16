Sequel.migration do
  change do
    add_column :activities, :user_id, String
  end
end