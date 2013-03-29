module Broker
class Seeding
  class << self
    #(DB.tables - [:schema_migrations]).each do |table|
    #    DB.run("TRUNCATE TABLE #{table} CASCADE;")
    #end
    @@dependences = {
      :pool             => :pool_family,
      :provider_account => [:provider, :pool_family],
      :image            => :provider,
      :instance         => [:hardware_profile, :image, :pool, :provider_account],
      :instance_ec2     => [:hardware_profile, :image, :pool, :provider_account],
    }

    @@seeded = {}
    @@cache = {}

    def [](key)
      @@cache[key]
    end

    def cleanup_cache
      @@seeded = {}
    end

    def cleanup_database
      Image.truncate
      HardwareProfile.truncate
      ProviderAccount.truncate(:cascade=>true)
      Provider.truncate
      Pool.truncate
      PoolFamily.truncate(:cascade=>true)
      cleanup_cache
    end

    def seed(*models)
      models.each { |model| seed_one(model) }
    end

    def seed_one(model)
      return if @@seeded[model]
      deps = @@dependences[model]
      Array(deps).each { |dep| seed_one(dep) }
      self.send(model)
      @@seeded[model] = true
    end

    def pool_family
      @@cache[:pf_1] = PoolFamilyService::create_pool_family(nil,
        :name => 'my first pf',
      )
      @@cache[:pf_2] = PoolFamilyService::create_pool_family(nil,
        :name => 'my second pf',
      )
      @@cache[:pf_ec2] = PoolFamilyService::create_pool_family(nil,
        :name => 'ec2 pf',
      )
    end

    def pool
      @@cache[:pool_1] = PoolService::create_pool(nil,
        :name => 'my first pool',
        :pool_family_id => @@cache[:pf_1].id,
      )
      @@cache[:pool_ec2] = PoolService::create_pool(nil,
        :name => 'ec2 pool',
        :pool_family_id => @@cache[:pf_ec2].id,
      )
    end

    def provider
      @@cache[:ec2_provider] = ProviderService::create_provider(nil,
        :name => 'my ec2',
        :type => ProviderService::EC2,
        :url  => 'local',
      )
      @@cache[:mock_provider] = ProviderService::create_provider(nil,
        :name => 'my mock',
        :type => ProviderService::MOCK,
        :url  => 'local',
      )
    end

    def provider_account
      @@cache[:ec2_acc] = ProviderAccountService::create_provider_account(nil,
        :name => 'ec2 test',
        :provider_id => @@cache[:ec2_provider].id,
        :credentials =>
        {
          :api_user     => ENV['ec2_api_user'],
          :api_password => ENV['ec2_api_password'],
          :api_provider => ENV['ec2_api_provider'],
        },
        :pool_family_ids => [@@cache[:pf_ec2].id],
      )

      @@cache[:mock_acc] = ProviderAccountService::create_provider_account(nil,
        :name => 'mock test',
        :provider_id => @@cache[:mock_provider].id,
        :credentials =>
        {
          :user     => 'mockuser',
          :password => 'mockpassword'
        },
        :pool_family_ids => [@@cache[:pf_1].id],
      )
    end

    def image
      @@cache[:image_1] = ImageService::create_image(nil,
        :broker_image_id   => 'rhel64',
        :provider_image_id => 'ami-1248812002',
        :provider_id       => @@cache[:ec2_provider].id,
      )
      @@cache[:image_2] = ImageService::create_image(nil,
        :broker_image_id   => 'rhel64',
        :provider_image_id => 'mock-1248812002',
        :provider_id       => @@cache[:mock_provider].id,
      )
    end

    def hardware_profile
      @@cache[:hwp_1] = HardwareProfileService::create_hardware_profile(nil, {
        :name         => t = 'some-crap',
        :memory       => '512MB',
        :storage      => '10GB',
        :cpu          => 1,
        :architecture => 'i386'
      })
      #binding.pry
    end

    def instance
      # FIXME: this should be called automatically when provider_account is added
      #HardwareProfileImportService.import(Seeding[:mock_acc])
      @@cache[:instance_1] = LaunchService.launch(Seeding[:pool_1].id, l_name='random launch name', Seeding[:hwp_1].name, Seeding[:image_1].broker_image_id)
    end

    # careful: launch a REAL instance on ec2
    def instance_ec2
      @@cache[:fedora_image] = ImageService::create_image(nil,
        :broker_image_id   => 'fedora',
        :provider_image_id => 'ami-bafcf3ce',
        :provider_id       => @@cache[:ec2_provider].id,
      )
      @@cache[:instance_ec2] = LaunchService.launch(Seeding[:pool_ec2].id, 'test instance '+Time.now.to_i.to_s, Seeding[:hwp_1].name, Seeding[:fedora_image].broker_image_id,
        #:flavor  => 'm1-small',
        :keyname => 'mpovolny'
      )
    end
  end
end
end
