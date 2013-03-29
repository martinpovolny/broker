module Broker
# class provides services need by DC driver from the broker
# thus being the layer between the two
class DCService
  def initialize(pool_name)
    @pool_name = pool_name
  end

  def hardware_profiles
    #HardwareProfileService::get_hardware_profiles(nil)
    # FIXME: perms
    # FIXME: split front/backend hwps
    HardwareProfileService::get_frontend_hardware_profiles(nil)
  end
  def images
    ImageService::get_frontend_images(nil) # FIXME: this should be
    # FIXME: perms
    # broker-level pluggable so we have to call the right class here
    # but the pluggable can be done on ImageService layer
    # but... the ImageService serving the REST interface probably needs more
    # methods then just the broker would need if image service is suplied by
    # imfac or otherwise...
  end

  def launch_instance(instance_name, hwp_id, image_id)
    # FIXME: perms: check permissions for the pool
    pool_id = Pool.where(:name => @pool_name).first.id
    LaunchService.launch(pool_id, instance_name, hwp_id, image_id)
  end

  def instances
    pool_id = Pool.where(:name => @pool_name).first.id
    InstanceService::get_instances_in_pool(nil, pool_id)
  end

  def realms
    OpenStruct.new(:id => 'default', :name => 'default')
  end
end
end
