require 'sequel'
DB = Sequel.connect('postgres://broker:broker@localhost/broker')

$: << 'lib'
require 'broker/models'
require 'broker/services'
require 'broker/services/hwp_import'
require 'broker/services/dc'

require 'seeding'

Broker::Seeding::seed(:provider, :pool_family, :provider_account)
