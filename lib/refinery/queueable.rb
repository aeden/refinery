module Refinery
  module Queueable
    # Get a named queue
    def queue(name)
      queue_provider.queue(name)
    end
    
    protected
    def queue_provider
      @queue_provider ||= RightAws::SqsGen2.new(
        config['aws']['credentials']["access_key_id"], 
        config['aws']['credentials']["secret_access_key"],
        {:multi_thread => true}
      )
    end
  end
end