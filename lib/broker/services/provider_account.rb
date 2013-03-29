module Broker
class ProviderAccountService
  class << self
    def get_provider_accounts(authctx)
      @provider_account = ProviderAccount.order(Sequel.asc(:id)).all
    end

    def get_provider_account(authctx, provider_account_id)
      @provider_account = ProviderAccount[provider_account_id]
      raise NotFound if @provider_account.nil?
      @provider_account
    end

    def delete_provider_account(authctx, pool_id)
      @provider_account = ProviderAccount[params[:id]]
      raise NotFound if @provider_account.nil?
      @provider_account.delete
    end

    def create_provider_account(authctx, provider_account_params)
      @provider_account = ProviderAccount.create(check_params(provider_account_params))
      if provider_account_params.key?(:pool_family_ids)
        pfs = provider_account_params[:pool_family_ids]
        @provider_account.remove_all_pool_families
        pfs.each {|pf| @provider_account.add_pool_family(pf)}
      end

      #HwpImportWorker::perform_async(@provider_account)
      #QC.enqueue('HardwareProfileImportService.import', @provider_account.id)
      HardwareProfileImportService.import(@provider_account.id)
      @provider_account
    end

    def modify_provider_account(authctx, provider_account_params)
      @provider_account = ProviderAccount[provider_account_params[:id]] rescue nil
      raise NotFound if @provider_account.nil?

      #@provider_account = check_params(pool_params[:provider_account_id])

      ProviderAccount.update(check_params(provider_account_params))

      # FIXME: pool_family_ids
    end

    private
    def check_params(provider_account_params)
      # FIXME whitelist!
      # filter input hash, allowing only valid params to pass
      # raising exceptions as needed
      provider_account_params.select{|k,v| [:pool_family_ids].index(k).nil?}
    end
  end
end
end
