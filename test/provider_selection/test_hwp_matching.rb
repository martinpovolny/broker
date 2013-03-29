require 'sequel_helper'
require 'qc_helper'
require 'provider_selection/hardware_profile'

Broker::Seeding::cleanup_database

##########################################################################
module Broker
class HwpMatchingTest < BrokerTestCase
  def test_match
    Seeding::seed(:provider_account, :provider)
    binding.pry
  
    frontend_hwp1 = HardwareProfileService::create_hardware_profile(nil, {
      :name         => 'front_1',
      :memory       => { :kind=> 'fixed', :unit=> 'MB',    :value=> 512 },
      :storage      => { :kind=> 'fixed', :unit=> 'GB',    :value=> 10 },
      :cpu          => { :kind=> 'fixed', :unit=> 'count', :value=> 1 },
      :architecture => { :kind=> 'fixed', :unit=> 'label', :value=> 'i386' },
    })
    frontend_hwp1.extend(ProviderSelection::HardwareProfile)

    frontend_hwp2 = HardwareProfileService::create_hardware_profile(nil, {
      :name         => 'front_2',
      :memory       => { :kind=> 'fixed', :unit=> 'MB',    :value=> 512 },
      :storage      => { :kind=> 'fixed', :unit=> 'GB',    :value=> 10 },
      :cpu          => { :kind=> 'fixed', :unit=> 'count', :value=> 1 },
      :architecture => { :kind=> 'fixed', :unit=> 'label', :value=> 'x86_64' },
    })
    frontend_hwp2.extend(ProviderSelection::HardwareProfile)

    backend_hwp1 = HardwareProfileService::create_hardware_profile(nil, {
      :name         => 'back_1',
      :memory       => { :kind=> 'fixed', :unit=> 'MB',    :value=> 512 },
      :storage      => { :kind=> 'fixed', :unit=> 'GB',    :value=> 10 },
      :cpu          => { :kind=> 'fixed', :unit=> 'count', :value=> 1 },
      :architecture => { :kind=> 'fixed', :unit=> 'label', :value=> 'i386' },
      :provider_id => Seeding[:mock_provider].id,
    })
    backend_hwp1.extend(ProviderSelection::HardwareProfile)
    assert(backend_hwp1.sufficient_for?(frontend_hwp1), 'backend_hwp1 should suffice frontend_hwp1')
    assert(!backend_hwp1.sufficient_for?(frontend_hwp2), 'backend_hwp1 should not suffice frontend_hwp2')

    backend_hwp2 = HardwareProfileService::create_hardware_profile(nil, {
      :name         => 'back_2',
      :memory       => { :kind=> 'fixed', :unit=> 'MB',    :value=> 500 },
      :storage      => { :kind=> 'fixed', :unit=> 'GB',    :value=> 10 },
      :cpu          => { :kind=> 'fixed', :unit=> 'count', :value=> 1 },
      :architecture => { :kind=> 'fixed', :unit=> 'label', :value=> 'i386' },
      :provider_id => Seeding[:mock_provider].id,
    })
    backend_hwp2.extend(ProviderSelection::HardwareProfile)
    assert(!backend_hwp2.sufficient_for?(frontend_hwp1), 'backend_hwp2 should not suffice frontend_hwp1')

    # FIXME add tests for ranges
  end
end
end
