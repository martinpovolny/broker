require 'sequel_helper'
require 'broker_service'

module Broker
class BrokerRESTTest < BrokerTestCase
  include Rack::Test::Methods

  def app
    BrokerController
  end

  def test_pools_return_array
    get '/pools'
    assert last_response.ok?
    pools = JSON.parse(last_response.body)
    assert(Array===pools, 'should return array')
  end

  def test_create_provider
    put '/providers', {
      :name => 'my mock',
      :type => 0,
      :url  => 'local',
    }.to_json, "content_type" => "application/json"
    assert_equal(201, last_response.status, 'should respond created')
    provider = JSON.parse(last_response.body)
    assert(Hash===provider, 'provider should be a hash')
  end

  def test_create_provider_account
    Seeding::seed(:provider, :pool_family)
    put '/provider_accounts', {
      :name => 'mock test',
      :provider_id => Seeding[:mock_provider].id,
      :credentials =>
      {
        :user     => 'mockuser',
        :password => 'mockpassword'
      },
      :pool_family_ids => [Seeding[:pf_1].id]
    }.to_json, "content_type" => "application/json"
    assert_equal(201, last_response.status, 'should respond created')
    account = JSON.parse(last_response.body)
    assert(Hash===account, 'account should be a hash')
  end

  def test_hardware_profiles_returns_array
    Seeding::seed(:hardware_profile)
    get '/hardware_profiles'
    assert(last_response.ok?, 'should respond ok')
    profiles = JSON.parse(last_response.body)
    assert(Array===profiles, 'should return array')
  end
end
end
