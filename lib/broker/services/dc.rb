module Broker
class DC
  $:<< '/home/martin/Projects/dc/deltacloud-client/lib/'
  require 'deltacloud/client'

  def self.for_account(provider_type,acc)
    case provider_type
    when 0 then self.for_mock_account(acc)
    when 1 then self.for_ec2_account(acc)
    else nil
    end
  end

  private
  def self.for_ec2_account(acc)
    dc = Deltacloud::Connect(:ec2, acc.credentials[:api_user], acc.credentials[:api_password])
    dc.use_provider(acc.credentials[:api_provider])
  end

  def self.for_mock_account(acc)
    Deltacloud::Connect(:mock, acc.credentials[:user], acc.credentials[:password])
  end

  def self.for_broker_account(acc)
    Deltacloud::Connect(:broker, acc.credentials[:user], acc.credentials[:password], acc.credentials[:pool])
  end
end
end
