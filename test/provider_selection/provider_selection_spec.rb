require './provider_selection.rb'

describe ProviderAccount do
  before(:each) do
    @hwp_large = HardwareProfile.new(
      :memory => 4,
      :cpu    => 2,
      :disk   => 100
    )

    @hwp_small = HardwareProfile.new(
      :memory => 4,
      :cpu    => 1,
      :disk   => 5
    )
  end

  describe '#sufficient_for?' do
    it "returns true on itself" do
      @hwp_small.sufficient_for?(@hwp_small).should be_true
      @hwp_large.sufficient_for?(@hwp_large).should be_true
    end

    it "returns false on larger profile" do
      @hwp_small.sufficient_for?(@hwp_large).should be_false
      @hwp_small.sufficient_for?(HardwareProfile.new(:memory => 5, :cpu => 1, :disk => 5)).should be_false
      @hwp_small.sufficient_for?(HardwareProfile.new(:memory => 4, :cpu => 2, :disk => 5)).should be_false
      @hwp_small.sufficient_for?(HardwareProfile.new(:memory => 4, :cpu => 1, :disk => 6)).should be_false
    end

    it "returns true on smaller profile" do
      @hwp_large.sufficient_for?(@hwp_small).should be_true
    end
  end

  describe 'load_yaml' do
    it 'should load from yaml' do
      acc1 = ProviderAccount.load_from_yaml <<EOD
name: account 1
hardware_profiles:
  - memory: 4
    cpu   : 1
    disk  : 5
  - memory: 4
    cpu   : 2
    disk  : 100
EOD
    end
  end
end
