#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.  The
# ASF licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.

require 'ipaddr'

#require_relative '../../runner'
require 'broker/services/dc-service'

module Deltacloud::Drivers::Broker

  class BrokerDriver < Deltacloud::BaseDriver

    define_instance_states do
      start.to( :pending )       .on( :create )

      pending.to( :running )     .automatically

      running.to( :running )     .on( :reboot )
      running.to( :stopped )     .on( :stop )

      stopped.to( :running )     .on( :start )
      stopped.to( :finish )      .on( :destroy )
    end

    feature :instances,
      :user_name,
      :user_Data,
      :authentication_key,
      :metrics,
      :realm_filter

    feature :images,
      :user_name,
      :user_description

    #cimi features
    feature :machines, :default_initial_state do
      { :values => ["STARTED"] }
    end
    feature :machines, :initial_states do
      { :values => ["STARTED", "STOPPED"]}
    end

    def initialize
      @client = Broker::DCService.new(api_provider) # we take the pool_name from the api_provider
    end

    define_hardware_profile('default')

    def hardware_profiles(credentials, opts = {})
      results = []
      safely do
        results = @client.hardware_profiles.collect do |f|
          HardwareProfile.new(f[:id].to_s) do
            architecture 'x86_64'
            memory f[:ram].to_i
            storage f[:disk].to_i
          end
        end
      end
      #filter_hardware_profiles(results, opts)
    end

    def realms(credentials, opts={})
      ## FIXME: implement for broker
      #check_credentials( credentials )
      #results = []
      #safely do
      #  # This hack is used to test if client capture exceptions correctly
      #  # To raise an exception do GET /api/realms/50[0-2]
      #  raise "DeltacloudErrorTest" if opts and opts[:id] == "500"
      #  raise "NotImplementedTest" if opts and opts[:id] == "501"
      #  raise "ProviderErrorTest" if opts and opts[:id] == "502"
      #  raise "ProviderTimeoutTest" if opts and opts[:id] == "504"
      #  results = [
      #    Realm.new(
      #      :id=>'us',
      #      :name=>'United States',
      #      :limit=>:unlimited,
      #      :state=>'AVAILABLE'
      #    ),
      #    Realm.new(
      #      :id=>'eu',
      #      :name=>'Europe',
      #      :limit=>:unlimited,
      #      :state=>'AVAILABLE'
      #    ),
      #  ]
      #end
      #results = filter_on( results, opts, :id )
      results = @client.realms
    end

    def filter_by_owner(credentials, images, owner_id)
      # FIXME: probably remove
      return images unless owner_id
      if owner_id == 'self'
        images.select { |e| e.owner_id == credentials.user }
      else
        filter_on(images, { :owner_id => owner_id}, :owner_id )
      end
    end

    #
    # Images
    #
    def convert_image(image, hwps)
      # There is not support for 'name' for now
      Image.new(
        :id                => image.broker_image_id, # image[:aws_id],
        :name              => image.broker_image_id, #; image[:aws_name] || image[:aws_id],
        :description       => image.broker_image_id, #image[:aws_description] || image[:aws_location],
        :owner_id          => 'fake owner', # image[:aws_owner],
        :architecture      => 'i386', # image[:aws_architecture],
        :hardware_profiles => hwps, #image_profiles(image, profiles),
        :state             => 'unknown', #image[:aws_state],
        :root_type         => 'wtf?' #convert_root_type(image[:aws_root_device_type])
      )
    end

    def images(credentials, opts={})
      # FIXME: implement for broker
      #check_credentials(credentials) # fixme, enable auth
      hwps   = @client.hardware_profiles
      images = @client.images.collect {|i| convert_image(i,hwps) }

      images = filter_on(images, opts, :id, :architecture)
      images = filter_by_owner(credentials, images, opts[:owner_id])

      # Add hardware profiles to each image
      #images = images.map { |i| (i.hardware_profiles = hardware_profiles(nil)) && i }
      #images = images.map { |i| (i.hardware_profiles = ['small','big']) && i }

      images.sort_by{|e| [e.owner_id, e.description]}
    end

    def create_image(credentials, opts={})
      # FIXME: implement for broker
      check_credentials(credentials)

      instance = instance(credentials, opts)

      safely do
        raise 'CreateImageNotSupported' unless instance and instance.can_create_image?
        image = {
          :id => opts[:name],
          :name => opts[:name],
          :owner_id => 'root',
          :state => "AVAILABLE",
          :description => opts[:description],
          :architecture => 'i386'
        }
        @client.store(:images, image)
        Image.new(image)
      end
    end

    def destroy_image(credentials, id)
      # FIXME: implement for broker
      check_credentials( credentials )
      @client.destroy(:images, id)
    end

    #
    # Instances
    #

    def instance(credentials, opts={})
      exit
      #check_credentials( credentials )
      #if instance = @client.load_collection(:instances, opts[:id])
      #  Instance.new(instance)
      #end
    end

    def instances(credentials, opts={})
      # FIXME: implement for broker
      #check_credentials( credentials )
      instances = @client.instances.collect do |broker_instance|
        Instance.new(broker_instance)
      end
      #opts.merge!( :owner_id => credentials.user ) unless opts.has_key?(:owner_id)
      #filter_on(instances, opts, :owner_id, :id, :state, :realm_id)
    end

    def generate_instance_id
      # FIXME: implement for broker
     # ids = @client.members(:instances)
      rand.to_s
      #count, next_id = 0, ''
      #loop do
      #  break unless ids.include?(next_id = "inst#{count}")
      #  count = count + 1
      #end
      #next_id
    end

    #def create_instance(credentials, image_id, opts={})
    #  # FIXME: implement for broker
    #  check_credentials( credentials )

    #  instance_id = generate_instance_id
    #  realm_id = opts[:realm_id] || realms(credentials).first.id

    #  if opts[:hwp_id]
    #    hwp = find_hardware_profile(credentials, opts[:hwp_id], image_id)
    #  else
    #    hwp = find_hardware_profile(credentials, 'm1-small', image_id)
    #  end

    #  name = opts[:name] || "i-#{Time.now.to_i}"

    #  initial_state = opts[:initial_state] || "RUNNING"

    #  instance = {
    #    :id => instance_id,
    #    :name => name,
    #    :state => (initial_state == "STARTED" ? "RUNNING" : initial_state),
    #    :keyname => opts[:keyname],
    #    :image_id => image_id,
    #    :owner_id => credentials.user,
    #    :public_addresses => [
    #      InstanceAddress.new("#{image_id}.#{instance_id}.public.com", :type => :hostname)
    #    ],
    #    :private_addresses =>[
    #      InstanceAddress.new("#{image_id}.#{instance_id}.private.com", :type => :hostname)
    #    ],
    #    :instance_profile => InstanceProfile.new(hwp.name, opts),
    #    :realm_id => realm_id,
    #    :create_image => true,
    #    :actions => instance_actions_for((initial_state == "STARTED" ? "RUNNING" : initial_state)),
    #    :user_data => opts[:user_data] ? Base64::decode64(opts[:user_data]) : nil
    #  }

    #  @client.store(:instances, instance)
    #  Instance.new( instance )
    #end

    def create_instance(credentials, image_id, opts={})
      Instance.new(@client.launch_instance(opts[:name], opts[:hwp_id], image_id))
      #ec2 = new_client(credentials)
      #instance_options = {}
      #if opts[:user_data]
      #  instance_options[:user_data] = Base64::decode64(opts[:user_data])
      #end
      #if opts[:metrics] and !opts[:metrics].empty?
      #  instance_options[:monitoring_enabled] = true
      #end
      #if opts[:realm_id]
      #  az, sn = opts[:realm_id].split(":")
      #  if sn
      #    instance_options[:subnet_id] = sn
      #  else
      #    instance_options[:availability_zone] = az
      #  end
      #end
      #instance_options[:key_name] = opts[:keyname] if opts[:keyname]
      #instance_options[:instance_type] = opts[:hwp_id] if opts[:hwp_id] && opts[:hwp_id].length > 0
      #firewalls = opts.inject([]){|res, (k,v)| res << v if k =~ /firewalls\d+$/; res}
      #instance_options[:group_ids] = firewalls unless firewalls.empty?
      #if opts[:instance_count] and opts[:instance_count].length != 0
      #  instance_options[:min_count] = opts[:instance_count]
      #  instance_options[:max_count] = opts[:instance_count]
      #end
      #if opts[:snapshot_id] and opts[:device_name]
      #  instance_options[:block_device_mappings] = [{
      #    :snapshot_id => opts[:snapshot_id],
      #    :device_name => opts[:device_name]
      #  }]
      #end
      #safely do
      #  new_instances = ec2.launch_instances(image_id, instance_options).collect do |i|
      #    convert_instance(i)
      #  end
      #  if new_instances.size == 1
      #    new_instances.first
      #  else
      #    new_instances
      #  end
      #end
    end

    def update_instance_state(credentials, id, state)
      # FIXME: implement for broker
      instance  = @client.load_collection(:instances, id)
      Instance.new(@client.store(:instances, instance.merge(
        :state => state,
        :actions => instance_actions_for(state)
      )))
    end

    def start_instance(credentials, id)
      # FIXME: implement for broker
      update_instance_state(credentials, id, 'RUNNING')
    end

    def reboot_instance(credentials, id)
      # FIXME: implement for broker
      update_instance_state(credentials, id, 'RUNNING')
    end

    def stop_instance(credentials, id)
      # FIXME: implement for broker
      update_instance_state(credentials, id, 'STOPPED')
    end

    def destroy_instance(credentials, id)
      # FIXME: implement for broker
      check_credentials( credentials )
      @client.destroy(:instances, id)
    end

    # mock object to mimick Net::SSH object
    class BrokerSSH
      # FIXME: implement for broker
      attr_accessor :command
    end

    def run_on_instance(credentials, opts={})
      # FIXME: implement for broker
      ssh = BrokerSSH.new
      ssh.command = opts[:cmd]
      Deltacloud::Runner::Response.new(
        ssh,
        "This is where the output from '#{ssh.command}' would appear if this were not a mock provider"
      )
    end

    #
    # Storage Volumes
    #
    def storage_volumes(credentials, opts={})
      check_credentials(credentials)
      filter_on(@client.build_all(StorageVolume), opts, :id)
    end

    def create_storage_volume(credentials, opts={})
      check_credentials(credentials)
      opts[:capacity] ||= "1"
      volume_id = "volume_#{Time.now.to_i}"
      volume = @client.store(:storage_volumes, {
        :id => volume_id,
        :name => opts[:name] ? opts[:name] : "Volume#{volume_id}",
        :created => Time.now.to_s,
        :state => "AVAILABLE",
        :capacity => opts[:capacity],
      })
      StorageVolume.new(volume)
    end

    def destroy_storage_volume(credentials, opts={})
      check_credentials(credentials)
      @client.destroy(:storage_volumes, opts[:id])
    end

    #opts: {:id=,:instance_id,:device}
    def attach_storage_volume(credentials, opts={})
      check_credentials(credentials)
      attach_volume_instance(opts[:id], opts[:device], opts[:instance_id])
    end

    def detach_storage_volume(credentials, opts={})
      check_credentials(credentials)
      detach_volume_instance(opts[:id], opts[:instance_id])
    end

    # FIXME: implementation idea:
    #
    # For some functions we could do a simple passthrough through the broker
    # driver to the underlying actual cloud provider drive once we have an
    # instance (or something else?) to tell us what the underlying provider is.

    # #
    # # Storage Snapshots
    # #

    # def storage_snapshots(credentials, opts={})
    #   check_credentials( credentials )
    #   filter_on(@client.build_all(StorageSnapshot), opts, :id)
    # end

    # def create_storage_snapshot(credentials, opts={})
    #   check_credentials(credentials)
    #   id = "store_snapshot_#{Time.now.to_i}"
    #   snapshot = {
    #         :id => id,
    #         :created => Time.now.to_s,
    #         :state => "COMPLETED",
    #         :storage_volume_id => opts[:volume_id],
    #   }
    #   snapshot.merge!({:name => opts[:name]}) if opts[:name]
    #   snapshot.merge!({:description => opts[:description]}) if opts[:description]
    #   StorageSnapshot.new(@client.store(:storage_snapshots, snapshot))
    # end

    def destroy_storage_snapshot(credentials, opts={})
      check_credentials(credentials)
      @client.destroy(:storage_snapshots, opts[:id])
    end

    def keys(credentials, opts={})
      check_credentials(credentials)
      filter_on(@client.build_all(Key), opts, :id)
    end

    def key(credentials, opts={})
      keys(credentials, opts).first
    end

    def create_key(credentials, opts={})
      check_credentials(credentials)
      key_hash = {
        :id => opts[:key_name],
        :credential_type => :key,
        :fingerprint => Key::generate_mock_fingerprint,
        :pem_rsa_key => Key::generate_mock_pem
      }
      safely do
        raise "KeyExist" if @client.load_collection(:keys, key_hash[:id])
        Key.new(@client.store(:keys, key_hash))
      end
    end

    def destroy_key(credentials, opts={})
      key = key(credentials, opts)
      @client.destroy(:keys, key.id)
    end

    def addresses(credentials, opts={})
      check_credentials(credentials)
      filter_on(@client.build_all(Address), opts, :id)
    end

    def create_address(credentials, opts={})
      check_credentials(credentials)
      Address.new(@client.store(:addresses, {
        :id => allocate_mock_address.to_s,
        :instance_id => nil
      }))
    end

    def destroy_address(credentials, opts={})
      check_credentials(credentials)
      address = @client.load_collection(:addresses, opts[:id])
      raise "AddressInUse" unless address[:instance_id].nil?
      @client.destroy(:addresses, opts[:id])
    end

    def associate_address(credentials, opts={})
      check_credentials(credentials)
      address = @client.load_collection(:addresses, opts[:id])
      raise "AddressInUse" unless address[:instance_id].nil?
      instance = @client.load_collection(:instances, opts[:instance_id])
      address[:instance_id] = instance[:id]
      instance[:public_addresses] = [InstanceAddress.new(address[:id])]
      @client.store(:addresses, address)
      @client.store(:instances, instance)
    end

    def disassociate_address(credentials, opts={})
      check_credentials(credentials)
      address = @client.load_collection(:addresses, opts[:id])
      raise "AddressNotInUse" unless address[:instance_id]
      instance = @client.load_collection(:instances, address[:instance_id])
      address[:instance_id] = nil
      instance[:public_addresses] = [
        InstanceAddress.new("#{instance[:image_id]}.#{instance[:id]}.public.com", :type => :hostname)
      ]
      @client.store(:addresses, address)
      @client.store(:instances, instance)
    end

    # #--
    # # Buckets
    # #--
    # def buckets(credentials, opts={})
    #   check_credentials(credentials)
    #   buckets = @client.build_all(Bucket)
    #   blob_map = @client.load_all(:blobs).inject({}) do |map, blob|
    #     map[blob[:bucket]] ||= []
    #     map[blob[:bucket]] << blob[:id]
    #     map
    #   end
    #   buckets.each { |bucket| bucket.blob_list = blob_map[bucket.id] }
    #   filter_on( buckets, opts, :id)
    # end

    # #--
    # # Create bucket
    # #--
    # def create_bucket(credentials, name, opts={})
    #   check_credentials(credentials)
    #   bucket = {
    #     :id => name,
    #     :name=>name,
    #     :size=>'0',
    #     :blob_list=>[]
    #   }
    #   @client.store(:buckets, bucket)
    #   Bucket.new(bucket)
    # end

    # #--
    # # Delete bucket
    # #--
    # def delete_bucket(credentials, name, opts={})
    #   check_credentials(credentials)
    #   bucket = bucket(credentials, {:id => name})
    #   raise 'BucketNotExist' if bucket.nil?
    #   raise "BucketNotEmpty" unless bucket.blob_list.empty?
    #   @client.destroy(:buckets, bucket.id)
    # end

    # #--
    # # Blobs
    # #--
    # def blobs(credentials, opts = {})
    #   check_credentials(credentials)
    #   blobs = @client.build_all(Blob)
    #   opts.merge!( :bucket => opts.delete('bucket') )
    #   filter_on(blobs, opts, :id, :bucket)
    # end

    # #--
    # # Blob content
    # #--
    # def blob_data(credentials, bucket_id, blob_id, opts = {})
    #   check_credentials(credentials)
    #   if blob = @client.load_collection(:blobs, blob_id)
    #     #give event machine a chance
    #     sleep 1
    #     blob[:content].split('').each {|part| yield part}
    #   end
    # end

    # #--
    # # Create blob
    # #--
    # def create_blob(credentials, bucket_id, blob_id, blob_data, opts={})
    #   check_credentials(credentials)
    #   blob_meta = BlobHelper::extract_blob_metadata_hash(opts)
    #   blob = {
    #     :id => blob_id,
    #     :name => blob_id,
    #     :bucket => bucket_id,
    #     :last_modified => Time.now,
    #     :user_metadata => BlobHelper::rename_metadata_headers(blob_meta, ''),
    #   }
    #   if blob_data.kind_of? Hash
    #     blob_data[:tempfile].rewind
    #     blob.merge!({
    #       :content_length => blob_data[:tempfile].length,
    #       :content_type => blob_data[:type],
    #       :content => blob_data[:tempfile].read
    #     })
    #   elsif blob_data.kind_of? String
    #     blob.merge!({
    #       :content_length => blob_data.size,
    #       :content_type => 'text/plain',
    #       :content => blob_data
    #     })
    #   end
    #   update_bucket_size(bucket_id, :plus)
    #   Blob.new(@client.store(:blobs, blob))
    # end

    # #--
    # # Delete blob
    # #--
    # def delete_blob(credentials, bucket_id, blob_id, opts={})
    #   check_credentials(credentials)
    #   safely do
    #     raise "NotExistentBlob" unless @client.load_collection(:blobs, blob_id)
    #     update_bucket_size(bucket_id, :minus)
    #     @client.destroy(:blobs, blob_id)
    #   end
    # end

    # #--
    # # Get metadata
    # #--
    # def blob_metadata(credentials, opts={})
    #   check_credentials(credentials)
    #   (blob = @client.load_collection(:blobs, opts[:id])) ? blob[:user_metadata] : nil
    # end

    # #--
    # # Update metadata
    # #--
    # def update_blob_metadata(credentials, opts={})
    #   check_credentials(credentials)
    #   safely do
    #     if blob = @client.load_collection(:blobs, opts[:id])
    #       @client.store(:blobs, blob.merge(
    #         :user_metadata => BlobHelper::rename_metadata_headers(opts['meta_hash'], '')
    #       ))
    #     else
    #       false
    #     end
    #   end
    # end

    # #--
    # # Metrics
    # #--
    # def metrics(credentials, opts={})
    #   check_credentials(credentials)
    #   instances(credentials).map do |inst|
    #     metric = Metric.new(
    #       :id     => inst.id,
    #       :entity => inst.name
    #     )
    #     Metric::MOCK_METRICS_NAMES.each { |metric_name| metric.add_property(metric_name) }
    #     metric.properties.sort! { |a,b| a.name <=> b.name }
    #     metric
    #   end
    # end

    # def metric(credentials, opts={})
    #   metric = metrics(credentials).first
    #   metric.properties.each { |p| p.generate_mock_values! }
    #   metric
    # end

    private

    def check_credentials(credentials)
      safely do
        if ( credentials.user != 'mockuser' ) or ( credentials.password != 'mockpassword' )
          raise 'AuthFailure'
        end
      end
    end
    alias :new_client :check_credentials

    # Broker allocation of 'new' address
    # There is a synchronization problem (but it's the mock driver,
    # mutex seemed overkill)
    #
    def allocate_mock_address
      addresses = []
      @client.members(:addresses).each do |addr|
        addresses << IPAddr.new("#{addr}").to_i
      end
      IPAddr.new(addresses.sort.pop+1, Socket::AF_INET)
    end

    def attach_volume_instance(volume_id, device, instance_id)
      volume = @client.load_collection(:storage_volumes, volume_id)
      instance = @client.load_collection(:instances, instance_id)
      volume[:instance_id] = instance_id
      volume[:device] = device
      volume[:state] = "IN-USE"
      instance[:storage_volumes] ||= []
      instance[:storage_volumes] << {volume_id=>device}
      @client.store(:storage_volumes, volume)
      @client.store(:instances, instance)
      StorageVolume.new(volume)
    end

    def detach_volume_instance(volume_id, instance_id)
      volume = @client.load_collection(:storage_volumes, volume_id)
      instance = @client.load_collection(:instances, instance_id)
      volume[:instance_id] = nil
      device = volume[:device]
      volume[:device] = nil
      volume[:state] = "AVAILABLE"
      instance[:storage_volumes].delete({volume_id => device}) unless instance[:storage_volumes].nil?
      @client.store(:storage_volumes, volume)
      @client.store(:instances, instance)
      StorageVolume.new(volume)
    end

    exceptions do

      on /AuthFailure/ do
        status 401
        message "Authentication Failure"
      end

      on /BucketNotEmpty/ do
        status 403
        message "Delete operation not valid for non-empty bucket"
      end

      on /KeyExist/ do
        status 403
        message "Key with same name already exists"
      end

      on /AddressInUse/ do
        status 403
      end

      on /AddressNotInUse/ do
        status 403
      end

      on /BucketNotExist/ do
        status 404
      end

      on /CreateImageNotSupported/ do
        status 500
      end

      on /NotExistentBlob/ do
        status 500
        message "Could not delete a non existent blob"
      end

      on /DeltacloudErrorTest/ do
        status 500
        message "DeltacloudErrorMessage"
      end

      on /NotImplementedTest/ do
        status 501
        message "NotImplementedMessage"
      end

      on /ProviderErrorTest/ do
        status 502
        message "ProviderErrorMessage"
      end

      on /ProviderTimeoutTest/ do
        status 504
        message "ProviderTimeoutMessage"
      end
    end
  end
end
