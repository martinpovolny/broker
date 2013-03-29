require 'sequel_helper'
require 'qc_helper'

Broker::Seeding::cleanup_database

##########################################################################
module Broker
class BasicServicesTest < BrokerTestCase
  #def run
  #  Seeding.cleanup_database

  #  test_pool_family
  #  test_pool
  #end

  def test_pool_family
    pf = PoolFamilyService::create_pool_family(nil,
      :name => 'my first pf',
    )
    assert_not_nil(pf, 'pool family creation failed')

    pfs = PoolFamilyService::get_pool_families(nil)
    assert_not_nil(pfs, msg = 'pool families enumeration failed')
    assert_kind_of(Array, pfs, msg)

    pf2 = PoolFamilyService::get_pool_family(nil, pfs[0].id)
    assert_not_nil(pf2, 'getting pool family failed')
  end

  def test_pool
    Seeding::seed(:pool_family)

    pool = PoolService::create_pool(nil,
      :name => 'my first pool',
      :pool_family_id => Seeding[:pf_1].id,
    )
    assert_not_nil(pool, 'pool creation failed')
    pools = PoolService.get_pools(nil)
    pool2 = PoolService::get_pool(nil, pools[0].id)
  end

  def test_provider
    provider = ProviderService::create_provider(nil,
      :name => 'my ec2',
      :type => ProviderService::EC2,
      :url  => 'local',
    )
    assert_not_nil(provider, 'ec2 provider account creation failed')
    providers = ProviderService.get_providers(nil)
    provider2 = ProviderService.get_provider(nil, providers[0].id)
    assert_kind_of(Array, providers, 'providers enumeration failed')

    mock_provider = ProviderService::create_provider(nil,
      :name => 'my mock',
      :type => ProviderService::MOCK,
      :url  => 'local',
    )
    assert_not_nil(mock_provider, 'mock provider account creation failed')
  end

  def test_provider_acc
    Seeding::seed(:provider, :pool_family)

    acc = ProviderAccountService::create_provider_account(nil,
      :name => 'ec2 test',
      :provider_id => Seeding[:ec2_provider].id,
      :credentials =>
      {
        :api_user     => ENV['ec2_api_user'],
        :api_password => ENV['ec2_api_password'],
      },
    )
    accs = ProviderAccountService.get_provider_accounts(nil)
    acc2 = ProviderAccountService.get_provider_account(nil, accs[0].id)

    mock_acc = ProviderAccountService::create_provider_account(nil,
      :name => 'mock test',
      :provider_id => Seeding[:mock_provider].id,
      :credentials =>
      {
        :user     => 'mockuser',
        :password => 'mockpassword'
      },
      :pool_family_ids => [Seeding[:pf_1].id],
    )
    assert_not_nil(mock_acc, 'mock provider account creation failed')
  end

  def test_image
    Seeding::seed(:provider)

    image = ImageService::create_image(nil,
      :broker_image_id   => 'rhel64',
      :provider_image_id => 'ami-1248812002',
      :provider_id       => Seeding[:ec2_provider].id,
    )
    assert_not_nil(image, 'image creation failed')
    images = ImageService.get_images(nil)
    assert(images.length > 0, 'should have at least one image')

    images = ImageService.get_frontend_images(nil)
    assert(images.length > 0, 'should have at least one frontend image')

    image2 = ImageService::create_image(nil,
      :broker_image_id   => 'rhel64',
      :provider_image_id => 'mock-1248812002',
      :provider_id       => Seeding[:mock_provider].id,
    )
  end

  # # call is to be moved under provider/provider account
  # def test_hwp_import
  #   Seeding::seed(:provider_account)

  #   HardwareProfileImportService.import(Seeding[:mock_acc])
  #   HardwareProfileImportService.import(Seeding[:ec2_acc])
  #
  #   # FIXME: this is tested as part of provider_account tests
  #   # FIXME: add assertions
  # end

  def test_hardware_profiles
    Seeding::seed(:provider_account, :provider)
    hwp = HardwareProfileService::create_hardware_profile(nil, {
      :name         => 'some-crap',
      :memory       => '512MB',
      :storage      => '10GB',
      :cpu          => 1,
      :architecture => 'i386'
    })
    assert_not_nil(hwp, 'frontend hwp creation failed')

    hwps = HardwareProfileService::get_hardware_profiles(nil)
    assert(hwps.length > 0, 'should have at least one hardware profile')

    hwps = HardwareProfileService::get_frontend_hardware_profiles(nil)
    assert(hwps.length > 0, 'should have at least one hardware profile')

    hwp = HardwareProfileService::get_hardware_profile(nil, hwps[0].id)
    assert_not_nil(hwp, 'get_hardware_profile failed')
  end

  def test_launch
    Seeding::seed(:hardware_profile, :image, :pool, :provider_account)
    # waiting for HardwareProfileImportService.import(Seeding[:mock_acc])
    QC::TestHelper::go! 
    binding.pry

    handle = LaunchService.launch(Seeding[:pool_1].id, 'random launch name', Seeding[:hwp_1].name, Seeding[:image_1].broker_image_id)
  end

  def test_instaces
    Seeding::seed(:hardware_profile, :image, :pool, :provider_account)
    # wait for HardwareProfileImportService.import(Seeding[:mock_acc])
    QC::TestHelper::go! 

    binding.pry

    handle = LaunchService.launch(Seeding[:pool_1].id, l_name='random launch name', Seeding[:hwp_1].name, Seeding[:image_1].broker_image_id)
    l_instance = Instance.where(:name => l_name).all[0]

    assert_not_nil(handle, 'instance launch failed')
    assert_not_nil(l_instance, m='instance entiry creation failed')
    assert_equal(l_instance.name, l_name, m)

    instances = InstanceService::get_instances(nil)
    assert_not_nil(instances, msg = 'instance enumeration failed')
    assert_kind_of(Array, instances, msg)

    instance = InstanceService::get_instance(nil, instances[0].id)
    assert_not_nil(instance, 'getting instance failed')
  end
end
end
