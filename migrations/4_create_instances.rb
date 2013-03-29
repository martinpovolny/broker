Sequel.migration do
  up do
    create_table(:instances) do
      primary_key :id                    # | integer                     | not null default nextval('instances_id_seq'::regclass)
      String :external_key              # | character varying(255)      |
      String :name                      # | character varying(1024)     | not null
      foreign_key :hardware_profile_id  # | integer                     | not null
      String :provider_hardware_profile
      foreign_key :frontend_realm_id    # | integer                     |
      Integer     :owner_id         # FIXME: fix when adding permissions       | integer                     |
      foreign_key :pool_id              # | integer                     | not null
      #foreign_key :pool_family_id       # redundant? we got this from the pool   | integer                     |
      foreign_key :provider_account_id  # | integer                     |
      String :public_addresses        # | character varying(255)      |
      String :private_addresses       # | character varying(255)      |
      String :state            # FIXME we need an enum or int state and make state transitions according to some state machine | character varying(255)      |
      String :last_error       #       | text                        |
      # lock_version            | integer                     | default 0
      # acc_pending_time        | integer                     | default 0
      # acc_running_time        | integer                     | default 0
      # acc_shutting_down_time  | integer                     | default 0
      # acc_stopped_time        | integer                     | default 0
      # time_last_pending       | timestamp without time zone | 
      # time_last_running       | timestamp without time zone | 
      # time_last_shutting_down | timestamp without time zone | 
      # time_last_stopped       | timestamp without time zone | 
      DateTime    :created_at   # | timestamp without time zone | not null
      DateTime    :updated_at   # | timestamp without time zone | not null
      # image_uuid              | character varying(255)      | 
      # image_build_uuid        | character varying(255)      | 
      # provider_image_uuid     | character varying(255)      | 
      # provider_instance_id    | character varying(255)      | 
      # user_data               | text                        | 
      # uuid                    | character varying(255)      | 
      # secret                  | character varying(255)      | 
      DateTime :deleted_at      # | timestamp without time zone | 
      DateTime :checked_at      # | timestamp without time zone | not null default '2012-10-17 07:13:05.205001'::timestamp without time zone
      # FIXME: store instance hwp info somewhere? instance_hwp_id         | integer                     | 
#Indexes:
#    "instances_pkey" PRIMARY KEY, btree (id)
#    "index_instances_on_deleted_at" btree (deleted_at)
#Foreign-key constraints:
#    "instances_pool_family_id_fk" FOREIGN KEY (pool_family_id) REFERENCES pool_families(id)
#    "instances_pool_id_fk" FOREIGN KEY (pool_id) REFERENCES pools(id)
#    "instances_provider_account_id_fk" FOREIGN KEY (provider_account_id) REFERENCES provider_accounts(id)
#Referenced by:
#    TABLE "instance_keys" CONSTRAINT "instance_keys_instance_id_fk" FOREIGN KEY (instance_id) REFERENCES instances(id)
    end
  end
  down do
    drop_table(:instances)
  end
end

