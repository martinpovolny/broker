# sequel -m path/to/migrations postgres://host/database

Sequel.migration do
  up do
    create_table(:pools) do
      primary_key :id
      String :name, :null=>false
    end
    create_table(:pool_families) do
    end
    create_table(:providers) do
    end
    create_table(:provider_accounts) do
    end
    create_table(:quotas) do
    end
    create_table(:provider_selection_strategies) do
    end
  end
  down do
    drop_table(:pools)
    drop_table(:pool_families)
    drop_table(:providers)
    drop_table(:provider_accounts)
    drop_table(:quotas)
    drop_table(:provider_selection_strategies)
  end
end

