Sequel.migration do
  up do
    create_table(:images) do
      String      :broker_image_id,   :null=>false
      String      :provider_image_id, :null=>false
      foreign_key :provider_id
      unique [:broker_image_id, :provider_id]
    end
  end
  down do
    drop_table(:images)
  end
end
