module Refinery
  module Queueable
    # Get a named queue
    def queue(name)
      queue_provider.queue(name)
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