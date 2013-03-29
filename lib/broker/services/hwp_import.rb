require 'queue_classic'
ENV['QC_DATABASE_URL']='postgres://broker:broker@localhost/broker'

module Broker
class HardwareProfileImportService
  class << self
    def import(acc)
      acc = ProviderAccount[acc] if Fixnum === acc

      dc = DC.for_account(acc.provider.type,acc)
      raise DCError.new('failed to instantiate cloud provider interface') unless dc

      # FIXME: if the provider already has hardware profiles, do not refetch the:
      #self.transaction do
        dc.hardware_profiles.each do |dc_hwp|
          next if dc_hwp.name == 'opaque' # FIXME: other check for empty profile
          HardwareProfile.create(
            :external_key => dc_hwp.name,
            #:name         => dc_hwp.name,
            #:name => hardware_profile.id,
            :cpu          => property_to_hash(dc_hwp.cpu),
            :memory       => property_to_hash(dc_hwp.memory),
            :storage      => property_to_hash(dc_hwp.storage),
            :architecture => property_to_hash(dc_hwp.architecture),
            :provider_id  => acc.provider.id,
          )
        end
      #end
    end

    private
    def property_to_hash(prop)
      property = {
        :kind  => prop.kind.to_s,
        :unit  => prop.unit,
        :value => prop.value
      }
      case prop.kind.to_s
      when Deltacloud::Client::Helpers::Property::Range
        property[:range_from] = prop.range[:from]
        property[:range_to]   = prop.range[:to]
      when Deltacloud::Client::Helpers::Property::Enum
        property[:enum_entries] = prop.options
      end
      property
    end
  end
end
end
