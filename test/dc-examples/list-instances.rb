require 'deltacloud/client'
require 'text-table'
require 'pry'

dc = Deltacloud::Connect(:ec2, ENV['ec2_api_user'], ENV['ec2_api_password'])
dc = dc.use_provider(ENV['ec2_api_provider'])
p dc.instances.collect(&:name)

print Text::Table.new(:head => ['name', 'ip', 'state'], :rows =>
  dc.instances.collect{|i|
    [ i.name, Array(i.public_addresses).collect(&:to_s).join(', '), i.state ]
  }
).to_s

#client.instances[-1].stop!
