module Refinery
  class Worker
    include Refinery::Loggable
    
    def run(message)
      logger.debug "Executing worker #{self.class.name}"
      time = Benchmark.realtime do
        execute(message)
      end
      logger.debug "Completed worker #{self.class.name} in #{time} seconds"
    end
  end
end