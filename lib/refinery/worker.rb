module Refinery #:nodoc:
  # Base class for workers. Please subclasses of this in the workers
  # directory.
  class Worker 
    include Refinery::Loggable
    include Refinery::Configurable
    include Refinery::Utilities
    
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
      class_name = processor_config['workers']['data_store']['class'] rescue 'S3'
      ds_class = Moneta.const_get(camelize(class_name))
      (@data_store ||= {})[options] ||= ds_class.new(
        :access_key_id => config['aws']['credentials']['access_key_id'],  
        :secret_access_key => config['aws']['credentials']['secret_access_key'],
        :bucket => options[:bucket],
        :multi_thread => true
      )
    end
    
    private
    # Get's the config element starting at the processer
    def processor_config
      config['processors'][daemon.name]
    end
  end
end