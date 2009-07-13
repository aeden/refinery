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
      
      ThreadsWait.all_waits(*daemons) do |daemon|
        puts "a #{daemon.name} just died"
      end
      
      logger.debug "Processor #{key} is exiting"
    end
  end
end