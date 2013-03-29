module Broker
class PoolService
  class << self
    def get_pools(authctx)
      pools = Pool.order(Sequel.asc(:id)).all
    end

    def get_pool(authctx, pool_id)
      pool = Pool[pool_id]
      raise NotFound.new if pool.nil?
      pool
    end

    def delete_pool(authctx, pool_id)
      pool = Pool[params[:id]]
      raise NotFound.new if pool.nil?
      pool.delete
    end

    def create_pool(authctx, pool_params)
      pool_family = check_pool_family(pool_params[:pool_family_id])
      pool = Pool.create(check_pool_params(pool_params))
    end

    def modify_pool(authctx, pool_params)
      pool = Pool[pool_params[:id]] rescue nil
      raise NotFound.new if pool.nil?

      pool_family = check_pool_family(pool_params[:pool_family_id])

      Pool.update(check_pool_params(pool_params))
    end

    private
    def check_pool_family(pool_family_id)
      pool_family = PoolFamily[pool_family_id]
      raise InvalidRequest.new("PoolFamily #{pool_family_id} does not exist") unless pool_family
    end

    # allow only params that are allowed to be modified through the interface
    def check_pool_params(pool_params)
      # FIXME
      pool_params
    end
  end
end
end
