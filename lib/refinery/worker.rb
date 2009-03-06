module Refinery #:nodoc:
  # Base class for workers. Please subclasses of this in the workers
  # directory.
  class Worker 
    include Refinery::Loggable
    include Refinery::Configurable
    
    def initialize(daemon)
      @daemon = daemon
    end
    
    # Run the worker with the given message
    def run(message)
      logger.debug "Executing worker #{self.class.name}"
      time = Benchmark.realtime do
        execute(message)
      end
      logger.debug "Completed worker #{self.class.name} in #{time} seconds"
    end
    
    def data_store(options)
      (@data_store ||= {})[options] ||= Moneta::S3.new(
        :access_key_id => config['aws']['credentials']['access_key_id'],  
        :secret_access_key => config['aws']['credentials']['secret_access_key'],
        :bucket => options[:bucket]
      )
    end
  end
end