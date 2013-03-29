# sequel -m migrations postgres://broker:broker@localhost/broker

Sequel.migration do
  up do
    create_table(:hardware_profiles) do
      primary_key :id           # | integer                     | not null default nextval('hardware_profiles_id_seq'::regclass)
      String      :external_key # | character varying(255)      | 
      String      :name         # | character varying(1024)     | not null # FIXME: comment out when we have broker_hardware_profiles
      String      :memory       # | integer                     | 
      String      :storage      # | integer                     | 
      String      :cpu          # | integer                     | 
      String      :architecture # | integer                     | 
      foreign_key :provider_id  # | integer                     | 
      #lock_version    # | integer                     | default 0
      DateTime    :created_at   # | timestamp without time zone | not null
      DateTime    :updated_at   # | timestamp without time zone | not null
      #deleted_at      # | timestamp without time zone | 
      #unique [:external_key, :provider_id] FIXME: uncoment when hwps are split in two
    end

    # fixme: in next step we split the front/back-end profiles to two entities
    #        to make the model associations and constrations more straight-forward
    # create_table(:broker_hardware_profiles) do
    #   primary_key :id             # | integer                     | not null default nextval('hardware_profiles_id_seq'::regclass)
    #   String      :name, :unique  # | character varying(1024)     | not null
    #   String      :memory         # | integer                     | 
    #   String      :storage        # | integer                     | 
    #   String      :cpu            # | integer                     | 
    #   String      :architecture   # | integer                     | 
    #   #lock_version               # | integer                     | default 0
    #   DateTime    :created_at     # | timestamp without time zone | not null
    #   DateTime    :updated_at     # | timestamp without time zone | not null
    #   #deleted_at                 # | timestamp without time zone | 
    # end
  end
  down do
    drop_table(:hardware_profiles)
    #drop_table(:broker_hardware_profiles)
  end
end
