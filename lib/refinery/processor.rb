module Refinery #:nodoc:
  # This class is used to monitor all of the threads for a single
  # processor.
  class Processor < Thread
    include Refinery::Configurable
    include Refinery::Loggable
    
    attr_reader :server
    attr_reader :key
    attr_reader :settings
    attr_reader :daemons
    
    # Initialize the processor.
    def initialize(server, key, settings={})
      @server = server
      @key = key
      @settings = settings
      @daemons = []
      super do
        execute
      end
    end
    
    private
    # Execute the processor
    def execute
      queue_prefix = config['prefix'] || ''
      
      logger.debug "Creating daemons for #{key}"
      1.upto(settings['workers']['initial']) do
        daemons << Daemon.new(self, key, queue_prefix, settings)
      end
      
      logger.debug "Running #{daemons.length} daemons"
      
      wait = ThreadsWait.new(*daemons)
      wait.all_waits do |daemon|
        logger.debug "a #{daemon.name} just died"
        daemons.delete(daemon)
        logger.debug "waiting for 60 seconds before starting a new #{key} daemon"
        sleep(60)
        logger.debug "starting a new #{key} daemon"
        daemon = Daemon.new(self, key, queue_prefix, settings)
        daemons << daemon
        wait.join(daemon)
      end
      
      logger.debug "Processor #{key} is exiting"
    end
  end
end