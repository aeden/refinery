module Refinery #:nodoc:
  # Base class for workers. Please subclasses of this in the workers
  # directory.
  class Worker 
    include Refinery::Loggable
    
    # Run the worker with the given message
    def run(message)
      logger.debug "Executing worker #{self.class.name}"
      time = Benchmark.realtime do
        execute(message)
      end
      logger.debug "Completed worker #{self.class.name} in #{time} seconds"
    end
  end
end