module Refinery
  class Worker
    include Refinery::Loggable
    
    def run(message)
      logger.debug "Executing worker: #{self.class.name}"
      execute(message)
    end
  end
end