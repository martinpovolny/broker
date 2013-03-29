class ProviderAccount
  attr_reader :name

  def initialize(name, hwps)
    @name = name
    @hardware_profiles = hwps
  end

  def matching_profiles(hardware_profile)
    @hardware_profiles.find_all { |hwp|
      hwp.sufficient_for?(hardware_profile)
    }
  end

  def lowest_matching_hwp(hardware_profile)
    # FIXME
    matching_profiles(hardware_profile)[0]
  end

  def self.load_from_yaml(yaml_string)
    yaml = YAML.load(yaml_string)
    ProviderAccount.new(
      yaml['name'],
      yaml['hardware_profiles'].collect {|h| HardwareProfile.new(h)}
    )
  end

  # verify that the provider has provider image for our (template) image
  def has_image?(image)
    # FIXME
    true
  end
end

class HardwareProfile
  def sufficient_for?(backend_hwp)
    failed = false
    @properties.each_pair { |type, property|
      failed ||= ! property.sufficient_for?(backend_hwp.get_property(type))
    }
    !failed
  end

  def initialize(prop_hash)
  #def initialize(account, prop_hash)
    #@account = account
    initialize_properties(prop_hash)
  end

  def get_property(type)
    @properties[type]
  end

  private
  def initialize_properties(prop_hash)
    @properties = {}
    prop_hash.each_pair { |type, value|
      @properties[type] = HardwareProperty.new(type, value)
    }
  end
end

class HardwareProperty
  attr_reader :type
  attr_reader :value

  def initialize(type, value)
    @type = type
    @value = value
  end

  # we match if we have more or equal
  def sufficient_for?(other_property)
    @type == other_property.type && @value >= other_property.value
  end
end

CBMatch = Struct.new(:provider, :hwps)
class BlueprintMatches
  attr_reader :matches

  def initialize(providers)
    @matches = providers.collect do |provider|
      CBMatch.new(provider, [])
    end
  end

  def filter_by_blueprint(c_blue)
    providers.each_with_index do |provider, index|
      if provider.has_image?(c_blue.image) and
        ! (hwp = provider.lowest_matching_hwp(c_blue.hwp)).nil?
        @matches[index].hwps << hwp
      else
        @matches[index] = null # invalidate this provider
      end
    end
    @matches.compact!
  end

  def providers
    @matches.collect(&:provider)
  end
end

class Pool
  def initialize(name, providers, strategies=[])
    @name = name
    @providers = providers
  end

  def blueprint_matches(blueprint)
    matches = BlueprintMatches.new(@providers)
    blueprint.components.each do |c_blue|
      matches.filter_by_blueprint(c_blue)
    end
    matches
  end

  private
  def _matching_providers_for_component(c_blue, providers)
    matching = CBMatches.new
    providers.each do |provider|
    end
    matching
  end
end

class SelectionStrategy
  def initialize(params)
  end
end

class PenaltyForFailureSelectionStrategy < SelectionStrategy
end

class StrictOrderSelectionStrategy < SelectionStrategy
end

class CostSelectionStrategy < SelectionStrategy
end

class ProviderImage
  def initialize(name)
    @name = name
  end
end

ComponentBlueprint = Struct.new(:image, :hwp)

Blueprint = Struct.new(:components)

hwp_large = HardwareProfile.new(
  :memory => 4,
  :cpu    => 2,
  :disk   => 100
)

hwp_small = HardwareProfile.new(
  :memory => 4,
  :cpu    => 1,
  :disk   => 5
)

acc1 = ProviderAccount.new('acc1', [hwp_large, hwp_small])
acc2 = ProviderAccount.new('acc2', [hwp_small])

p hwp_small.sufficient_for?(hwp_large)
p hwp_small.sufficient_for?(hwp_small)
p hwp_large.sufficient_for?(hwp_small)
p hwp_large.sufficient_for?(hwp_large)

#dep

p acc1.matching_profiles(hwp_small).count
p acc1.matching_profiles(hwp_large).count

p acc2.matching_profiles(hwp_small).count
p acc2.matching_profiles(hwp_large).count

pool = Pool.new('default',[acc1, acc2])
#pool.

blueprint = Blueprint.new([
  ComponentBlueprint.new('e3728c41', hwp_small),
  ComponentBlueprint.new('f11ee8c4', hwp_small)
])

require 'pp'
matches = pool.blueprint_matches(blueprint)
pp matches
matches.matches.each do |m|
  puts m.provider.name
  p m.hwps
end
