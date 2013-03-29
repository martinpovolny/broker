module Broker
class LaunchService
  class << self
    def launch(pool_id, launch_name, hwp_name, image, opts={})
      # to make bug hunting easier, we quick-check the args here
      raise InvalidRequest.new('launch: invalid arguments') unless (Fixnum===pool_id)&&(String===launch_name)&&(String===hwp_name)&&(String===image)&&(Hash===opts)

      # FIXME: hwp matching
      # FIXME: provider seletion should fire here

      account = Pool[pool_id].pool_family.provider_accounts[0]
      provider = account.provider

      dc = DC.for_account(provider.type, account)
      provider_image = ImageService.find_provider_image_id(provider.id, image) # fixme: osetreni vyjimky neni image

      hwp = HardwareProfile.find(:name => hwp_name)  # fixme: osetreni vyjimky neni hwp
      raise InvalidRequest.new('broker hardware profile not found') if hwp.nil?

      provider_hwp = provider.hardware_profiles[0]
      raise InvalidRequest.new('provider hardware profile not found') if provider_hwp.nil?

      launch_args = {
        #:image_id    => provider_image,
        :hwp_id      => provider_hwp.external_key,
        :name        => launch_name, # instance.name.tr("/", "-"),
        # FIXME: normalize units
        :hwp_memory  => 512, # instance.instance_hwp.memory,
        :hwp_cpu     => 1,    # instance.instance_hwp.cpu,
        :hwp_storage => 1024, # instance.instance_hwp.storage,
        # FIXME: keyname
        :keyname     => (instance.instance_key.name rescue nil)
      }.merge(opts)

      instance = Instance.create(
        :name                => launch_name,
        :provider_account_id => account.id,
        :hardware_profile_id => hwp.id,
        :provider_hardware_profile => provider_hwp.external_key,
        :pool_id             => pool_id,
        :state               => 'CREATED' # FIXME
      )

      #dc_args.merge!({:realm_id => match.realm.external_key}) if (match.realm.external_key.present? rescue false)
      #dc_args.merge!({:user_data => instance.user_data}) if instance.user_data.present?
      begin
        dc_instance = dc.create_instance(provider_image, launch_args)
        instance.update(:external_key => dc_instance.id)
      rescue Deltacloud::Client::AuthenticationError => e
        raise Broker::DCError.new(e.message)
        # FIXME: update database
      end
      instance
    end
  end

  #def self.create_instance!(task, match, config_server, config)
  #  begin
  #    task.state = Task::STATE_PENDING
  #    task.save!

  #    if config_server and config.present?
  #      task.instance.add_instance_config!(config_server, config)
  #    end
  #    task.instance.provider_account = match.provider_account
  #    task.instance.create_auth_key unless task.instance.instance_key

  #    task.instance.instance_hwp = create_instance_hwp(task.instance.hardware_profile, match.hardware_profile)
  #    dcloud_instance = create_dcloud_instance(task.instance, match)

  #    handle_dcloud_error(dcloud_instance)

  #    task.state = Task::STATE_RUNNING
  #    task.save!
  #    handle_instance_state(task.instance,dcloud_instance)
  #    task.instance.save!
  #  rescue HttpException => ex
  #    task.failure_code = Task::FAILURE_PROVIDER_CONTACT_FAILED
  #    handle_create_instance_error(task, ex)
  #  rescue Exception => ex
  #    handle_create_instance_error(task, ex)
  #  ensure
  #    task.instance.save! if task.instance.changed?
  #    task.save! if task.changed?
  #  end
  #end

  #def self.create_dcloud_instance(instance, match)
  #  client = match.provider_account.connect
  #  raise _('Could not connect to Provider Account.  Please contact an Administrator.') unless client

  #  client_args = {
  #    :image_id    => match.provider_image,
  #    :hwp_id      => match.hardware_profile.external_key,
  #    :name        => instance.name.tr("/", "-"),
  #    :hwp_memory  => instance.instance_hwp.memory,
  #    :hwp_cpu     => instance.instance_hwp.cpu,
  #    :hwp_storage => instance.instance_hwp.storage,
  #    :keyname     => (instance.instance_key.name rescue nil)
  #  }
  #  client_args.merge!({:realm_id => match.realm.external_key}) if (match.realm.external_key.present? rescue false)
  #  client_args.merge!({:user_data => instance.user_data}) if instance.user_data.present?
  #  client.create_instance(client_args)
  #end
end
end
