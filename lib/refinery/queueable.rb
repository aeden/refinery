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
    # the block. This method handles any exceptions that are raised
    # in the block and will recreate the provider automatically.
    #
    # Note that errors will not be propagated beyond this block. You
    # have been warned.
    def with_queue(name, &block)
      begin
        yield queue(name)
      rescue Exception => e
        logger.error "Queue error: #{e.message}"
        @queue_provider = nil
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