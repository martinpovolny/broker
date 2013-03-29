module Broker
class ProviderService
  MOCK  = 0 # FIXME: map to dc driver
  EC2   = 1
  RHEVM = 2

  class << self
    def get_providers(authctx)
      @provider = Provider.order(Sequel.asc(:id)).all
    end

    def get_provider(authctx, provider_id)
      @provider = Provider[provider_id]
      raise NotFound if @provider.nil?
      @provider
    end

    def delete_provider(authctx, provider_id)
      @provider = Provider[params[:id]]
      raise NotFound if @provider.nil?
      @provider.delete
    end

    def create_provider(authctx, provider_params)
      begin
        provider = Provider.create(check_provider_params(provider_params))
      rescue Sequel::DatabaseError => e
        raise DBError.new(e.message)
      end
    end

    def modify_provider(authctx, provider_params)
      @provider = Provider[provider_params[:id]] rescue nil
      raise NotFound if @provider.nil?

      #@provider = check_provider(provider_params[:provider_id])

      Provider.update(check_provider_params(provider_params))
    end

    private
    def check_provider_params(provider_params)
      # FIXME
      provider_params
    end
  end
end
end
