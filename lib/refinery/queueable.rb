module Refinery #:nodoc:
  # Mix this module in to classes that want to access a queue.
  module Queueable
    include Loggable
    include Configurable
    # Get a named queue
    def queue(name)
      queue_provider.queue(name)
    end
    
    # Given the queue name and a block, yield the named queue into 
    # the block.
    def with_queue(name, &block)
      begin
        yield queue(name)
      rescue Exception => e
        logger.error "An error occurred when communicating with queue #{name}: #{e.message}"
        puts e.backtrace.map { |t| "\t#{t}" }.join("\n")
        sleep(30)
      end
    end
    
    protected
    # Get the queue provider. Defaults to RightAws::SqsGen2 running
    # in multi-thread mode.
    def queue_provider
      if config['queue_engine'] == 'beanstalk' && defined?(Beanstalk)
        @queue_provider ||= Refinery::BeanstalkQueueProvider.new
      else
        if defined?(Typica)
          @queue_provider ||= Typica::Sqs::QueueService.new(
            config['aws']['credentials']["access_key_id"], 
            config['aws']['credentials']["secret_access_key"]
          )
        else
          @queue_provider ||= RightAws::SqsGen2.new(
            config['aws']['credentials']["access_key_id"], 
            config['aws']['credentials']["secret_access_key"],
            {:multi_thread => true}
          )
        end
      end
    end
  end
end