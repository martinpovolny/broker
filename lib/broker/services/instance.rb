module Broker
class InstanceService
  class << self
    def get_instances(authctx)
      instances = Instance.order(Sequel.asc(:id)).all
    end

    def get_instance(authctx, instance_id)
      instance = Instance[instance_id]
      raise NotFound.new if instance.nil?
      instance
    end

    def stop_instance(authctx, instance_id) # FIXME: whatever statechange request
    end

    def get_instances_in_pool(authctx, pool_id)
      instances = Instance.where(:pool_id=> pool_id).order(Sequel.asc(:id)).all
    end
  end
end
end
