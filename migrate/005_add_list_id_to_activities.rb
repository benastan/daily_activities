Sequel.migration do
  change do
    add_column :activities, :list_id, Integer
  end
end