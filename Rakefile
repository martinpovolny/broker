# FIXME, call actions from ruby

namespace :db do
  desc 'migrate database'
  task :migrate do
    system "sequel -m migrations postgres://broker:broker@localhost/broker"
  end
end

namespace :test do
  desc 'run functional tests'
  task :functional do
    system "bundle exec ruby -I test/ test/services/test_broker.rb"
  end

  desc 'run dc-driver functional'
  task :functional do
    system "bundle exec ruby -I test/ test/dc.rb"
  end

  desc 'run tracker functional'
  task :functional do
    system "bundle exec ruby -I test/ test/tracker.rb"
  end
end

#namespace :sq do
#  desc 'run sidekiq'
#  task :run do
#    system 'bundle exec sidekiq -r./lib/broker/workers.rb -c 50 -e production'
#  end
#end

require "queue_classic"
require "queue_classic/tasks"

ENV['QC_DATABASE_URL']='postgres://broker:broker@localhost/broker'
#bundle exec rake qc:create
