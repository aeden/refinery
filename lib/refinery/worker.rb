module Refinery #:nodoc:
  # Base class for workers. Place subclasses of this in the workers
  # directory.
  #
  # Workers may include validation logic to verify that the message 
  # has the correct keys and values before processing.
  class Worker 
    include Refinery::Loggable
    include Refinery::Configurable
    include Refinery::Utilities
    include Refinery::Validations
    include Refinery::Queueable
    
    # Initialize the worker with the given daemon.
    def initialize(daemon)
      @daemon = daemon
    end
    
    # Run the worker with the given message. The result from the worker's
    # <code>execute</code> method is returned along with the run time.
    #
    # Validation will occur prior to calling execute.
    def run(message)
      result = false
      
      validate(message)
      
      logger.debug "Executing worker #{self.class.name}"
      time = Benchmark.realtime do
        begin
          result = execute(message)
        rescue Exception => e
          logger.error "Error executing worker #{self.class.name}: #{e.message}"
          raise e
        end
      end
      logger.debug "Completed worker #{self.class.name} in #{time} seconds"
      return result, time
    end
    
    # Get the data store for the worker.
    #
    # The data store is provided through the Moneta interface.
    #
    # If the configuration providers a data_store:class option then that class
    # will be used (the class must be in the Moneta module), otherwise 
    # Moneta::S3 will be used.
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
    
    protected
    # Get's the config element starting at the processer
    def processor_config
      config['processors'][daemon.name]
    end
  end
end