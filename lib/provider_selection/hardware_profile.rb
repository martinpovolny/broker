module ProviderSelection
  class HwpProperty
    attr_reader :kind, :unit, :value

    def initialize(type,hash)
      @type = type
      @kind, @unit, @value = hash.values_at(:kind,:unit,:value)
      @value = @value.split('..').map(&:to_f) if @type == 'range'

      normalize
    end

    def sufficient_for?(other)
      raise '"other" property must be of kind "fixed"' unless other.kind == 'fixed'

      case @kind
      when 'fixed' then 'label' == @unit ? @value == other.value : @value >= other.value
      when 'enum'  then @value.detect(false){|v| v >= other.value}
      when 'range' then @value[1] <= other.value
      end
    end

    private

    # normalize GB to MB
    # more normalizations to be done when needed
    def normalize
      @value = case @kind
        when 'fixed' then @value*1024
        when 'enum', 'range' then @value.map{ |v| v*1024 }
      end if @unit == 'GB'
    end
  end

module HardwareProfile
  def properties
    [:memory, :storage, :cpu, :architecture]
  end

  def props
    @props ||= properties.reduce({}) { |props,prop| props.update(prop => HwpProperty.new(prop,self.send(prop))) }
  end

  def sufficient_for?(other_hwp)
    props.each_pair do |prop_key, prop|
      prop.sufficient_for?(other_hwp.props[prop_key]) or return false
    end
    true
  end

# broker=# select * from hardware_profiles;
#   id  | external_key | name |                       memory                        |                            storage                             |                       cpu                
#        |                        architecture                         | provider_id | created_at | updated_at 
# ------+--------------+------+-----------------------------------------------------+----------------------------------------------------------------+------------------------------------------
# -------+-------------------------------------------------------------+-------------+------------+------------
#  3379 | t1.micro     |      | {:kind=>"fixed", :unit=>"MB", :value=>"613"}        | {:kind=>"fixed", :unit=>"GB", :value=>"160"}                   | {:kind=>"fixed", :unit=>"count", :value=>
# "1"}   | {:kind=>"enum", :unit=>"label", :value=>["i386", "x86_64"]} |        1029 |            | 
#  3380 | m1.small     |      | {:kind=>"fixed", :unit=>"MB", :value=>"1740.8"}     | {:kind=>"fixed", :unit=>"GB", :value=>"160"}                   | {:kind=>"fixed", :unit=>"count", :value=>
# "1"}   | {:kind=>"enum", :unit=>"label", :value=>["i386", "x86_64"]} |        1029 |            | 
#  3381 | m1.medium    |      | {:kind=>"fixed", :unit=>"MB", :value=>"3840.0"}     | {:kind=>"fixed", :unit=>"GB", :value=>"410"}                   | {:kind=>"fixed", :unit=>"count", :value=>
# "2"}   | {:kind=>"enum", :unit=>"label", :value=>["i386", "x86_64"]} |        1029 |            | 
#  3382 | m1.large     |      | {:kind=>"fixed", :unit=>"MB", :value=>"7680.0"}     | {:kind=>"fixed", :unit=>"GB", :value=>"850"}                   | {:kind=>"fixed", :unit=>"count", :value=>
# "4"}   | {:kind=>"fixed", :unit=>"label", :value=>"x86_64"}          |        1029 |            | 
#  3383 | c1.medium    |      | {:kind=>"fixed", :unit=>"MB", :value=>"1740.8"}     | {:kind=>"fixed", :unit=>"GB", :value=>"350"}                   | {:kind=>"fixed", :unit=>"count", :value=>
# "5"}   | {:kind=>"enum", :unit=>"label", :value=>["i386", "x86_64"]} |        1029 |            | 
#  3384 | m2.xlarge    |      | {:kind=>"fixed", :unit=>"MB", :value=>"17510.4"}    | {:kind=>"fixed", :unit=>"GB", :value=>"420"}                   | {:kind=>"fixed", :unit=>"count", :value=>
# "6.5"} | {:kind=>"fixed", :unit=>"label", :value=>"x86_64"}          |        1029 |            | 
#  3385 | m1.xlarge    |      | {:kind=>"fixed", :unit=>"MB", :value=>"15360"}      | {:kind=>"fixed", :unit=>"GB", :value=>"1690"}                  | {:kind=>"fixed", :unit=>"count", :value=>
# "8"}   | {:kind=>"fixed", :unit=>"label", :value=>"x86_64"}          |        1029 |            | 
#  3386 | m2.2xlarge   |      | {:kind=>"fixed", :unit=>"MB", :value=>"35020.8"}    | {:kind=>"fixed", :unit=>"GB", :value=>"850"}                   | {:kind=>"fixed", :unit=>"count", :value=>
# "13"}  | {:kind=>"fixed", :unit=>"label", :value=>"x86_64"}          |        1029 |            | 
#  3387 | c1.xlarge    |      | {:kind=>"fixed", :unit=>"MB", :value=>"7168"}       | {:kind=>"fixed", :unit=>"GB", :value=>"1690"}                  | {:kind=>"fixed", :unit=>"count", :value=>
# "20"}  | {:kind=>"fixed", :unit=>"label", :value=>"x86_64"}          |        1029 |            | 
#  3388 | m2.4xlarge   |      | {:kind=>"fixed", :unit=>"MB", :value=>"70041.6"}    | {:kind=>"fixed", :unit=>"GB", :value=>"1690"}                  | {:kind=>"fixed", :unit=>"count", :value=>
# "26"}  | {:kind=>"fixed", :unit=>"label", :value=>"x86_64"}          |        1029 |            | 
#  3389 | m1-small     |      | {:kind=>"fixed", :unit=>"MB", :value=>"1740.8"}     | {:kind=>"fixed", :unit=>"GB", :value=>"160"}                   | {:kind=>"fixed", :unit=>"count", :value=>
# "1"}   | {:kind=>"fixed", :unit=>"label", :value=>"i386"}            |        1030 |            | 
#  3390 | m1-large     |      | {:kind=>"range", :unit=>"MB", :value=>7680..15360}  | {:kind=>"enum", :unit=>"GB", :value=>["850", "1024"]}          | {:kind=>"range", :unit=>"count", :value=>
# 1..6}  | {:kind=>"fixed", :unit=>"label", :value=>"x86_64"}          |        1030 |            | 
#  3391 | m1-xlarge    |      | {:kind=>"range", :unit=>"MB", :value=>12288..32768} | {:kind=>"enum", :unit=>"GB", :value=>["1024", "2048", "4096"]} | {:kind=>"fixed", :unit=>"count", :value=>
# "4"}   | {:kind=>"fixed", :unit=>"label", :value=>"x86_64"}          |        1030 |            | 
# (13 rows)

end
end
