module Broker
class Tracker
  MAX_AGE = 5 * 60 # 5 minutes in seconds

  def initialize(max_age=MAX_AGE, logger=nil)
    @max_age = max_age
    @logger  = logger
  end

  def logger
    @logger ||= Logger.new('log/tracker.log')
  end

  def run
    loop do
      @logger.info('starting polling loop')
      start_at = Time.now
      limit = Time.now - @max_age
      Instance.where{checked_at < limit}.or(:checked_at => nil).all do |instance|
        update_single_instance(instance)
        exit
      end
      @logger.info('ended polling loop')
      delta = Time.now - start_at
      sleep(@max_age-delta) if delta < @max_age
    end
  end

  private
  def update_single_instance(instance)
    #p instance
    #p instance.provider_account
    #p instance.provider_account.provider
    #p instance.provider_account.provider.type
    dc = DC::for_account(instance.provider_account.provider.type, instance.provider_account)
    p instance.name
    p instance.external_key
    
    dc_instance = dc.instance(instance.external_key)               
    #p dc_instance

    if dc_instance.nil?
      instance.update(
        :state      => 'DELETED',
        :checked_at => Time.now,
        :updated_at => Time.now
      )
    elsif dc_instance.state != instance.state
      instance.update(
        :state      => dc_instance.state,
        :checked_at => Time.now
      )
    else
      instance.update(
        :checked_at => Time.now
      )
    end

    binding.pry

    #dc.check instance state....
    #update instance state in db( :checked_at = Time.now.... )
  end
end
end

###########################3
class ConductorImpl                                                                                
def collect_accounts                                                            
  accounts = []                                                                 
  Pool.all.each do |pool|                                                       
    pool.instances.each do |instance|                                           
      if instance.provider_account and instance.state != Instance::STATE_NEW and not accounts.include?(instance.provider_account)
        accounts << instance.provider_account                                   
      end                                                                       
    end                                                                         
  end                                                                           
  accounts                                                                      
end                                                                             
                                                                                
# Extract 'ipv4' and 'hostname' addresses from Deltacloud                       
def extract_addresses(address_list)                                             
  addresses = []                                                                
  address_list.each do |address|                                                
    addresses << address[:address] if ['ipv4', 'hostname'].include?(address[:type])
  end                                                                           
  addresses                                                                     
end     

def check_one_account(account)                                                  
  connection = account.connect                                                  
  ignored_states = [Instance::STATE_NEW, Instance::STATE_STOPPED, Instance::STATE_CREATE_FAILED]
                                                                                
  account.instances.order("checked_at ASC").each do |instance|                  
    # the instance object can be staled                                         
    instance.reload                                                             
    # optimization; right now we ignore instances that are in the STOPPED, NEW, or CREATE_FAILED states.
    # when we get to stateful instances, this will need to change               
    if !ignored_states.include?(instance.state) or instance.stopped_after_creation?
      instance.update_attribute(:checked_at,Time.now)                           
                                                                                
      begin                                                                     
        api_instance = connection.instance(instance.external_key)               
      rescue Exception => e                                                     
        DBomaticLogger.instance.warn("caught deltacloud exception #{e} when updating instance #{instance.name}")
        api_instance = nil                                                      
      end                                                                       
                                                                                
      if api_instance                                                           
        instance.state = Taskomatic.dcloud_to_instance_state(api_instance.state)
                                                                                
        # only update the public and private addresses if they are not nil.     
        # this prevents us from deleting known information about instances      
        if (addresses = extract_addresses(api_instance.public_addresses)).present?
          instance.public_addresses = addresses.join(',')                       
        end                                                                     
        if (addresses = extract_addresses(api_instance.private_addresses)).present?
          instance.private_addresses = addresses.join(',')                      
        end                                                                     
        # Only update the instance / create an event if anything has changed!   
        instance.save! if instance.changed?                                     
      elsif instance.stop_request_queued? && instance.disappears_after_stop_request?
        # some providers (openstack, ec2) delete stopped instances              
        # so it probably makes sense to consider vanished instances, which      
        # we sent stop request to, as stopped                                   
        DBomaticLogger.instance.info("known instance missing from provider but stop request was sent before, marking #{instance.name} as stopped")
        instance.update_attribute(:state, Instance::STATE_STOPPED)              
      else                                                                      
        # We have an instance in our database, but it didn't come back over the API
        DBomaticLogger.instance.info("known instance missing from provider: #{instance.name} #{instance.external_key}")
        instance.update_attribute(:state, Instance::STATE_VANISHED)             
      end                                                                       
    end        

    # For RHEV, we need to start up the instance after the vm has been created  
    # and state changes from PENDING to STOPPED                                 
    if instance.requires_explicit_start?                                        
      DBomaticLogger.instance.info("sending explicit start request to #{instance.name}")
      begin                                                                     
        instance.start(nil)                                                     
      rescue                                                                    
        DBomaticLogger.instance.info("failed to start instance #{instance.name}: #{$!.message}")
      end                                                                       
    elsif instance.stuck_in_stopping?                                           
      DBomaticLogger.instance.info("sending second stop request to #{instance.name}, instance is stuck in stopping state")
      begin                                                                     
        instance.stop_with_event(nil)                                           
      rescue                                                                    
        DBomaticLogger.instance.info("failed to stop instance #{instance.name}: #{$!.message}")
      end                                                                       
    end                                                                         
  end                                                                           
end  
end  

