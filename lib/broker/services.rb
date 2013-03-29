# This file defines the public interface of the broker.
# 
# No XML, JSON, or any REST magick shall pass this point invards.
# All access to guts must go through here.
#
# Design guidelines:
#
# * no side effects except for the outer state of the Broker 
#   interface -- the database
#
# * all data passed in the parameters, no access to HTTP request, environment,
#   session whatever implementation detail of the RPC transport
#
# * all data is returned as function call return value
#
# * errors are returned as raised exception, no exception from this rules
#
# File broker/exception.rb defines the Exception classes; no other exception
# shall be returned or we are in an internal error state
#

require 'broker/exceptions'
require 'broker/services/pool'
require 'broker/services/pool_family'
require 'broker/services/provider'
require 'broker/services/provider_account'
require 'broker/services/hardware_profile'
require 'broker/services/image'
require 'broker/services/instance'

require 'broker/services/launch'
require 'broker/services/hwp_import'
require 'broker/services/dc'

