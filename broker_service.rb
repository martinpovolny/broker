require 'sinatra/base'
require 'sequel'

require 'rabl'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'builder'

require 'json'

# monekypatch some bulls*it load order conflict regarding Rabl
[Object, Array, FalseClass, Float, Hash, Integer, NilClass, String, TrueClass].each do |klass|
  klass.class_eval do
    # Dumps object in JSON (JavaScript Object Notation). See www.json.org for more info.
    def to_json(options = nil, foo = nil)
      ActiveSupport::JSON.encode(self, options)
    end
  end
end

Rabl.register!

$: << 'lib'
DB = Sequel.connect('postgres://broker:broker@localhost/broker')
require 'broker/models'
require 'broker/services'

#
# Below is a 'REST adapter' whose responsibility is to adapt the BrokerIntergace to
# provide RESTful service.
#
# * It acquires the authentication information
# * Parses the input parameters (json, xml?)
# * Calls apropriate BrokerInterface method
# * Formats the response
# * Translates the error state into the HTTP codes
#
# Nothing smart, no magick here to see, we just respect the line drawn by the
# interface.

module Broker
  class RESTAdapter < Sinatra::Base
    #configure { set :logging, true }
    #before {
    #  env['rack.logger'] = Logger.new('log/broker.log')
    #  log = File.new("log/sinatra.log", "a+")
    #  $stdout.reopen(log)
    #  $stderr.reopen(log)
    #  $stderr.sync = true
    #  $stdout.sync = true
    #}
    def json_body
      MultiJson.load(request.body.read, :symbolize_keys => true)
    end

    def get_auth_ctx
      nil
    end

    error BrokerError do |e|
      status 500
      e.message
    end

    error NotFound do |e|
      status 404
      e.message
    end

    error InvalidRequest do |e|
      status 422
      e.message
    end

    error Unauthorized do |e|
      status 401
      e.message
    end
  end

  # Below we have the restful resources

  class PoolAdapter < RESTAdapter
    get "/pools", :provides => [:json] do
      Rabl::Renderer.json(
        PoolService::get_pools(get_auth_ctx), 'pools', view_path: 'views')
    end

    get "/pools/:id", :provides => [:json] do |pool_id|
      Rabl::Renderer.json(
        PoolService::get_pool(get_auth_ctx, pool_id.to_i), 'pool', view_path: 'views')
    end

    put "/pools", :provides => [:json] do
      Rabl::Renderer.json(@pools, 'pools', view_path: 'views')
        [201, Rabl::Renderer.json(
          PoolService::create_pool(get_auth_ctx, json_body), 'pool', view_path: 'views')]
    end

    put "/pools/:id", :provides => [:json] do
      Rabl::Renderer.json(
        PoolService::modify_pool(get_auth_ctx, json_body), 'pool', view_path: 'views')
    end
  end

  class PoolFamilyAdapter < RESTAdapter
    get "/pool_families", :provides => [:json] do
      Rabl::Renderer.json(
        PoolFamilyService::get_pool_families(get_auth_ctx), 'pool_families', view_path: 'views')
    end

    get "/pool_families/:id", :provides => [:json] do |pool_id|
      Rabl::Renderer.json(
        PoolFamilyService::get_pool_family(get_auth_ctx, pool_id.to_i), 'pool_family', view_path: 'views')
    end

    put "/pool_families", :provides => [:json] do
      Rabl::Renderer.json(@pool_families, 'pool_families', view_path: 'views')
        [201, Rabl::Renderer.json(
          PoolFamilyService::create_pool_family(get_auth_ctx, json_body), 'pool_family', view_path: 'views')]
    end

    put "/pool_families/:id", :provides => [:json] do
      Rabl::Renderer.json(
        PoolFamilyService::modify_pool_family(get_auth_ctx, json_body), 'pool_family', view_path: 'views')
    end
  end

  class ProviderAdapter < RESTAdapter
    get "/providers", :provides => [:json] do
      Rabl::Renderer.json(
        ProviderService::get_providers(get_auth_ctx), 'providers', view_path: 'views')
    end

    get "/providers/:id", :provides => [:json] do |pool_id|
      Rabl::Renderer.json(
        ProviderService::get_provider(get_auth_ctx, pool_id.to_i), 'provider', view_path: 'views')
    end

    put "/providers", :provides => [:json] do
      [201, Rabl::Renderer.json(
        ProviderService::create_provider(get_auth_ctx, json_body), 'provider', view_path: 'views')]
    end

    put "/providers/:id", :provides => [:json] do
      Rabl::Renderer.json(
        ProviderService::modify_provider(get_auth_ctx, json_body), 'provider', view_path: 'views')
    end
  end

  class ProviderAccountAdapter < RESTAdapter
    get "/provider_accounts", :provides => [:json] do
      Rabl::Renderer.json(
        ProviderAccountService::get_provider_accounts(get_auth_ctx), 'provider_accounts', view_path: 'views')
    end

    get "/provider_accounts/:id", :provides => [:json] do |pool_id|
      Rabl::Renderer.json(
        ProviderAccountService::get_provider_account(get_auth_ctx, pool_id.to_i), 'provider_account', view_path: 'views')
    end

    put "/provider_accounts", :provides => [:json] do
      [201, Rabl::Renderer.json(
        ProviderAccountService::create_provider_account(get_auth_ctx, json_body), 'provider_account', view_path: 'views')]
    end

    put "/provider_accounts/:id", :provides => [:json] do
      Rabl::Renderer.json(
        ProviderAccountService::modify_provider_account(get_auth_ctx, json_body), 'provider_account', view_path: 'views')
    end
  end

  class HardwareProfileAdapter < RESTAdapter
    get "/hardware_profiles", :provides => [:json] do
      Rabl::Renderer.json(
        HardwareProfileService::get_hardware_profiles(get_auth_ctx), 'hardware_profiles', view_path: 'views')
    end

    get "/hardware_profiles/:id", :provides => [:json] do |pool_id|
      Rabl::Renderer.json(
        HardwareProfileService::get_hardware_profile(get_auth_ctx, pool_id.to_i), 'hardware_profile', view_path: 'views')
    end

    put "/hardware_profiles", :provides => [:json] do
      Rabl::Renderer.json(@hardware_profiles, 'hardware_profiles', view_path: 'views')
        [201, Rabl::Renderer.json(
          HardwareProfileService::create_hardware_profile(get_auth_ctx, json_body), 'hardware_profile', view_path: 'views')]
    end

    put "/hardware_profiles/:id", :provides => [:json] do
      Rabl::Renderer.json(
        HardwareProfileService::modify_hardware_profile(get_auth_ctx, json_body), 'hardware_profile', view_path: 'views')
    end
  end

#  class InstanceAdapter < RESTAdapter
#    get "/instances", :provides => [:json] do
#      Rabl::Renderer.json(
#        HardwareProfileService::get_instances(get_auth_ctx), 'instances', view_path: 'views')
#    end
#
#    get "/instances/:id", :provides => [:json] do |instance_id|
#      Rabl::Renderer.json(
#        HardwareProfileService::get_instance(get_auth_ctx, pool_id.to_i), 'instance', view_path: 'views')
#    end
#  end
end

class BrokerController < Sinatra::Base
  use Broker::PoolAdapter
  use Broker::PoolFamilyAdapter
  use Broker::ProviderAdapter
  use Broker::ProviderAccountAdapter
  use Broker::HardwareProfileAdapter
#  use Broker::InstanceAdapter

  if app_file == $0
    run!
  end

  # test route to actually launch something
  put '/launch', :provides => [:json]  do
    # [hwp, image]
  end
end

#if __FILE__ == $0
#  #run!
#  run Rack::Cascade, [Broker::PoolAdapter, Broker::PoolFamilyAdapter,
#                      Broker::ProviderAdapter, Broker::ProviderAccountAdapter,
#                      Broker::HardwareProfileAdapter]
#end
