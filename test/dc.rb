require 'sequel_helper'
# tests for the Deltacloud broker driver

# tests for the Deltacloud broker driver
module Broker
class DCDriverTest < BrokerTestCase

  def dc_broker_acc
    @dc ||= Deltacloud::Connect(:broker, 'boo', 'far', 'my first pool')
  end

  def test_hardware_profile
    Seeding::seed(:hardware_profile)

    dc_broker_acc.hardware_profiles.each do |hwp|
      p hwp
    end
  end

  def test_image_mock
    Seeding::seed(:image, :provider_account)

    dc = DC::for_account(ProviderService::MOCK,Seeding[:mock_acc])
    dc.images.each do |img|
      p img
    end
  end

  def test_image
    Seeding::seed(:image, :hardware_profile)

    dc_broker_acc.images.each do |img|
      p img
    end
  end

  def test_launch
    Seeding::seed(:image, :provider_account, :pool, :hardware_profile)
    #dc = DC::for_account(ProviderService::MOCK,Seeding[:mock_acc])
    #dc = DC::for_account(ProviderService::MOCK,Seeding[:mock_acc])
    dc = dc_broker_acc
    instance = dc.create_instance( Seeding[:image_1].broker_image_id,
      {
        :hwp_id      => Seeding[:hwp_1].name,
        :name        => i_name = 'some crazy instance name',
        # FIXME: normalize units
        :hwp_memory  => 512, # instance.instance_hwp.memory,
        :hwp_cpu     => 1,    # instance.instance_hwp.cpu,
        :hwp_storage => 1024, # instance.instance_hwp.storage,
        # FIXME: keyname
        :keyname     => "some key name"
      }
    )
    assert_not_nil(instance, 'instance should exist')
    assert_equal(i_name, instance.name, 'instance name must be set')
    # FIXME: hwp, hwp_properties, pool/account

    p instance
  end

  def test_instances
    #Seeding::seed(:instance)
    Seeding::seed(:instance_ec2)
    instances = dc_broker_acc.instances
    assert_kind_of(Array, instances, 'instances must return an array')

    instances.each do |instance|
      p instance
    end
  end

  def test_realms
    realms = dc_broker_acc.realms
    assert_kind_of(Array, realms, 'realms must return an array')

    realms.each do |realm|
      p realm
    end
  end
end
end
