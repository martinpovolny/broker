require 'test/unit'
require 'rack/test'
require 'test/unit/assertions'
include Test::Unit::Assertions
require 'pry'

$:<< '.'
#require 'broker_service'

require 'sequel'
DB = Sequel.connect('postgres://broker:broker@localhost/broker')

$: << 'lib'
require 'broker/models'
require 'broker/services'
require 'broker/services/hwp_import'
require 'broker/services/dc'

require 'seeding'

# Add a subclass
# Must use this class as the base class for your tests
class BrokerTestCase < Test::Unit::TestCase
  def run(*args, &block)
    result = nil
    Broker::Seeding::cleanup_cache
    Sequel::Model.db.transaction(:rollback=>:always){result = super}
    result
  end
end

## Or you could override the base implementation like this
#class MiniTest::Unit::TestCase
#  alias_method :_original_run, :run
#
#  def run(*args, &block)
#    result = nil
#    Sequel::Model.db.transaction(:rollback => :always) do
#      result = _original_run(*args, &block)
#    end
#    result
#  end
#end
