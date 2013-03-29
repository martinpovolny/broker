require 'deltacloud/client'
require 'pry'

dc = Deltacloud::Connect(:ec2, ENV['ec2_api_user'], ENV['ec2_api_password'])
dc = dc.use_provider(ENV['ec2_api_provider'])
p dc.realms

key_name = 'mpovolny'
unless client.keys.collect(&:name).find(key_name)
  STDERR.puts 'ssh key not found in the clouds'
  exit
end

# launch an instance with ssh key # ami-bafcf3ce   eu-west-1   x86_64
instance = client.create_instance( 'ami-bafcf3ce', {
  :name    => 'my fair instance', # FIXME: wrong key
  :flavor  => 'm1-small',
  :keyname => key_name
})

binding.pry
exit

instance.start!
#
# login into the instance
#
# shut down the instance

#instance.reboot!
binding.pry
instance.destroy!
