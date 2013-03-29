# Exception classes; no other exception shall be returned or we are in an
# internal error state

module Broker
  class BrokerError < Exception; end
  class NotFound < BrokerError; end         # would map to 404 in HTTP
  class InvalidRequest < BrokerError; end   # would map to 422 in HTTP
  class Unauthorized < BrokerError; end     # would map to 401 in HTTP  
  class DCError < BrokerError; end          # dc error, to be handled according to the context
  class DBError < BrokerError; end
end
