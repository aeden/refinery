module Refinery #:nodoc:
  # Mix this module in to classes that want to access a queue.
  module Queueable
    include Loggable
    include Configurable
    # Get a named queue
    def queue(name)
      queue_provider.queue(name)
    end
    
    def with_queue(name, &block)
      begin
        yield queue(name)
      rescue Exception => e
        logger.error "Queue error: #{e.message}"
        sleep(5)
        retry
      end
    end
    
    protected
    # Get the queue provider. Defaults to RightAws::SqsGen2 running
    # in multi-thread mode.
    def queue_provider
      @queue_provider ||= RightAws::SqsGen2.new(
        config['aws']['credentials']["access_key_id"], 
        config['aws']['credentials']["secret_access_key"],
        {:multi_thread => true}
      )
    end
  end
end