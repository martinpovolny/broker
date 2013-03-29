module Broker
class PoolFamilyService
  class << self
    def get_pool_families(authctx)
      pf = PoolFamily.order(Sequel.asc(:id)).all
    end

    def get_pool_family(authctx, pf_id)
      pf = PoolFamily[pf_id]
      raise NotFound if pf.nil?
      pf
    end

    def delete_pool_family(authctx, pool_id)
      pf = PoolFamily[params[:id]]
      raise NotFound if pf.nil?
      pf.delete
    end

    def create_pool_family(authctx, pf_params)
      begin
        pf = PoolFamily.create(check_pf_params(pf_params))
      rescue Sequel::DatabaseError => e
        raise DBError.new(e.message)
      end
    end

    def modify_pool_family(authctx, pf_params)
      pf = PoolFamily[pf_params[:id]] rescue nil
      raise NotFound if pool.nil?

      #pool_family = check_pool_family(pool_params[:pool_family_id])

      Pool.update(check_pf_params(pf_params))
    end

    private
    def check_pf_params(pf_params)
      # FIXME
      pf_params
    end
  end
end
end
