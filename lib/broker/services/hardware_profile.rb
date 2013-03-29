module Broker
class HardwareProfileService
  class << self
    def get_hardware_profiles(authctx)
      hardware_profile = HardwareProfile.order(Sequel.desc(:id)).all
    end

    def get_frontend_hardware_profiles(authctx)
      hardware_profile = HardwareProfile.where(:provider_id=>nil).order(Sequel.desc(:id)).all
    end

    def get_hardware_profile(authctx, hardware_profile_id)
      hardware_profile = HardwareProfile[hardware_profile_id]
      raise NotFound if hardware_profile.nil?
      binding.pry
      hardware_profile
    end

    def delete_hardware_profile(authctx, hardware_profile_id)
      hardware_profile = HardwareProfile[params[:id]]
      raise NotFound if hardware_profile.nil?
      hardware_profile.delete
    end

    def create_hardware_profile(authctx, hardware_profile_params)
      hardware_profile = HardwareProfile.create(check_hardware_profile_params(hardware_profile_params))
      #@provider = Provider[hardware_profile_params[:provider_id]] rescue nil
      #raise NotFound if @provider.nil?
    end

    def modify_hardware_profile(authctx, hardware_profile_params)
      hardware_profile = HardwareProfile[hardware_profile_params[:id]] rescue nil
      raise NotFound if hardware_profile.nil?

      #hardware_profile = check_hardware_profile(hardware_profile_params[:hardware_profile_id])

      HardwareProfile.update(check_hardware_profile_params(hardware_profile_params))
    end

    private
    def check_hardware_profile_params(hardware_profile_params)
      # FIXME
      hardware_profile_params
    end
  end
end
end
