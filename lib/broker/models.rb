#require 'multi_json'
require 'oj'
require 'sequel/plugins/serialization'

# custom json (de)serializer that creates hash keys as symbols
Sequel::Plugins::Serialization.register_format(
  :json_symbol,
  lambda {|v| Oj.dump(v, :pretty => true)},
  lambda {|v| Oj.load(v, :symbol_keys => true)}
  #lambda {|v| MultiJson.dump(v, :pretty => true)},
  #lambda {|v| MultiJson.load(v, :symbolize_keys => true)}
)

# hooks to track modification times for entities
module TrackModificationTimes
  def before_create; super; self.created_at = Time.now; end
  def before_save;   super; self.updated_at = Time.now; end
end

class Pool < Sequel::Model
  many_to_one :quota #, :autosave => true, :dependent => :destroy
  many_to_one :pool_family
#  has_many :provider_selection_strategies, :dependent => :destroy
#  has_many :provider_priority_groups, :dependent => :destroy
#  has_many :pool_provider_account_options, :dependent => :destroy
  include TrackModificationTimes
end

class PoolFamily < Sequel::Model
  one_to_many :pool
  one_to_one :quota
  many_to_many :provider_accounts
  #has_many :instances
  include TrackModificationTimes
end

class Provider < Sequel::Model
  one_to_many :provider_accounts
  one_to_many :hardware_profiles #, :dependent => :destroy
  one_to_many :provider_realms
  #one_to_many :realm_backend_targets, :as => :provider_realm_or_provider, :dependent => :destroy
  #one_to_many :frontend_realms, :through => :realm_backend_targets
  many_to_one :provider_type
  #one_to_many :provider_priority_group_elements, :as => :value, :dependent => :destroy
  #one_to_many :provider_priority_groups, :through => :provider_priority_group_elements
  include TrackModificationTimes
end

class ProviderAccount < Sequel::Model
  many_to_one :provider
  many_to_one :quota #, :autosave => true, :dependent => :destroy
  many_to_many :pool_families #, :uniq => true
  many_to_many :provider_realms #, :uniq => true
  # eventually, this might be "has_many", but first pass is one-to-one
  #  has_one :config_server, :dependent => :destroy
#FIXME  one_to_many :provider_priority_group_elements, :as => :value, :dependent => :destroy
#FIXME  one_to_many :pool_provider_account_options, :dependent => :destroy
#  has_many :events, :as => :source, :dependent => :destroy, :order => 'events.id ASC'

#  # Scopes
#  has_many :events, :as => :source, :dependent => :destroy,
#           :order => 'events.id ASC'
  include TrackModificationTimes
  plugin :serialization, :json_symbol, :credentials
end

class Quota < Sequel::Model
  # FIXME: one_to_one davame jen na stranu, kde NENI ulozen cizi klic,
  # zde JE, takze many to one
  many_to_one :pool_family
end

class ProviderSelectionStrategy < Sequel::Model
end

class HardwareProfile < Sequel::Model
  many_to_one :provider
  plugin :serialization, :json_symbol, :cpu
  plugin :serialization, :json_symbol, :memory
  plugin :serialization, :json_symbol, :storage
  plugin :serialization, :json_symbol, :architecture
end

class Image < Sequel::Model
  many_to_one :provider
end

class Instance < Sequel::Model
  many_to_one :provider_account
  many_to_one :pool
#Foreign-key constraints:
#    "instances_pool_family_id_fk" FOREIGN KEY (pool_family_id) REFERENCES pool_families(id)
#    "instances_pool_id_fk" FOREIGN KEY (pool_id) REFERENCES pools(id)
#    "instances_provider_account_id_fk" FOREIGN KEY (provider_account_id) REFERENCES provider_accounts(id)

  #include TrackModificationTimes
  # we do not include TrackModificationTimes because we want to have the ability 
  # to change :checked_at w/o changing :updated_at
  def before_create; super; self.created_at = Time.now; end
end
