require 'sequel_helper'
require 'broker/tracker'

Broker::Seeding::cleanup_database

module Broker
class BasicServicesTest < BrokerTestCase
  def test_tracker
    Seeding::seed(:instance)

    tracker = Tracker.new(5, Logger.new(STDERR))
    tracker.run
  end
end
end
