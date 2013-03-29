require 'sequel'

DB = Sequel.connect('postgres://broker:broker@localhost/broker')

class Pool < Sequel::Model
#  belongs_to :quota, :autosave => true, :dependent => :destroy
#  belongs_to :pool_family
#  has_many :provider_selection_strategies, :dependent => :destroy
#  has_many :provider_priority_groups, :dependent => :destroy
#  has_many :pool_provider_account_options, :dependent => :destroy
end

class PoolFamily < Sequel::Model
  one_to_many :pool
  one_to_one :quota
  many_to_many :provider_account
  #has_many :instances
end

class Provider < Sequel::Model
  one_to_many :provider_account
 # one_to_many :hardware_profiles, :dependent => :destroy
  one_to_many :provider_realm
  #one_to_many :realm_backend_targets, :as => :provider_realm_or_provider, :dependent => :destroy
  #one_to_many :frontend_realms, :through => :realm_backend_targets
  many_to_one :provider_type
  #one_to_many :provider_priority_group_elements, :as => :value, :dependent => :destroy
  #one_to_many :provider_priority_groups, :through => :provider_priority_group_elements
end

class ProviderAccount < Sequel::Model
  belongs_to :provider
  belongs_to :quota #, :autosave => true, :dependent => :destroy
  many_to_many :pool_family #, :uniq => true
  many_to_many :provider_realm #, :uniq => true
  has_many :credentials, :dependent => :destroy
  # eventually, this might be "has_many", but first pass is one-to-one
#  has_one :config_server, :dependent => :destroy
  has_many :provider_priority_group_elements, :as => :value, :dependent => :destroy
  has_many :pool_provider_account_options, :dependent => :destroy
#  has_many :events, :as => :source, :dependent => :destroy, :order => 'events.id ASC'

#  # Scopes
#  has_many :events, :as => :source, :dependent => :destroy,
#           :order => 'events.id ASC'
end

class Quota < Sequel::Model
  # FIXME: one to one davame jen na stranu, kde NENI ulozen cizi klic,
  # zde JE, takze many to one
  many_to_one :pool_family
end

class ProviderSelectionStrategy < Sequel::Model
end
