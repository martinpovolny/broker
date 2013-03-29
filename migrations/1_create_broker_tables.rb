# sequel -m migrations postgres://broker:broker@localhost/broker

Sequel.migration do
  up do
    create_table(:pools) do
      primary_key :id
      String      :name, :unique=>true, :null=>false   # | character varying(255)      | not null
      String      :exported_as                     # | character varying(255)      |
      foreign_key :quota_id                        # | integer                     |
      foreign_key :pool_family_id                  # | integer                     | not null
      #integer    lock_version                     # | integer                     | default 0
      DateTime    :created_at,      :null=>false   # | timestamp without time zone | not null
      DateTime    :updated_at,      :null=>false   # | timestamp without time zone | not null
      TrueClass   :enabled,         :default=>true # | boolean                     | default true
    end
    create_table(:pool_families) do
      primary_key :id
      String      :name, :unique=>true, :null=>false  # | character varying(255)      | not null
      String      :description                # | character varying(255)      |
      #Fixnum     :lock_version               # | integer                     | default 0
      DateTime    :created_at,  :null=>false  # | timestamp without time zone | not null
      DateTime    :updated_at,  :null=>false  # | timestamp without time zone | not null
      foreign_key :quota_id
    end
    create_table(:providers) do
      primary_key :id
      String    :name, :unique=>true, :null=>false # | character varying(255)      | not null
      String    :url,           :null=>false # | character varying(255)      | not null
      #Fixnum    :lock_version               # | integer                     | default 0
      DateTime  :created_at,    :null=>false # | timestamp without time zone | not null
      DateTime  :updated_at,    :null=>false # | timestamp without time zone | not null
      #foreign_key    :provider_type_id    # | integer                     | not null     <--- replaced with provider_type
      String    :deltacloud_provider # | character varying(255)      |
      Fixnum    :type
      TrueClass :enabled             # | boolean                     | not null default true
      TrueClass :available           # | boolean                     | not null default true
    end
    create_table(:provider_accounts) do
      primary_key :id
      String      :name, :unique=>true, :null=>false # | character varying(255)      | not null
      foreign_key :provider_id   # | integer                     | not null
      foreign_key :quota_id      # | integer                     |
      #Fixnum      :lock_version # | integer                    | default 0
      DateTime    :created_at, :null=>false
      DateTime    :updated_at, :null=>false
      String      :credentials
    end
    create_join_table(
      :provider_account_id => :provider_accounts,
      :pool_family_id      => :pool_families,
    )

    create_table(:quotas) do
      primary_key :id
      Fixnum   :total_instances, :default=>0 # | integer                     | default 0
      Fixnum   :maximum_running_instances# | integer                     |
      Fixnum   :maximum_total_instances  # | integer                     |
      #Fixnum   lock_version             # | integer                     | default 0
      DateTime :created_at, :null=>false # | timestamp without time zone | not null
      DateTime :updated_at, :null=>false # | timestamp without time zone | not null
    end
    create_table(:provider_selection_strategies) do
      primary_key :id
    end
  end
  down do
    drop_table(:pool_families_provider_accounts)
    drop_table(:pools)
    drop_table(:pool_families)
    drop_table(:providers)
    drop_table(:provider_accounts)
    drop_table(:quotas)
    drop_table(:provider_selection_strategies)
  end
end

