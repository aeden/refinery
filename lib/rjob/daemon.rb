module RJob
  class Daemon
    include RJob::Loggable
    include RJob::Configurable
    
    RUNNING = 'running'
    STOPPED = 'stopped'
    
    attr_accessor :state
    attr_reader :thread
    attr_reader :daemon_number
    
    # Start the daemon
    def self.start(server, daemon_number)
      RJob::Server.logger.info "Starting daemon #{daemon_number}"
      new(server, daemon_number)
    end
    
    def stop
      state = STOPPED
    end
    
    def state
      @state ||= RUNNING
    end
    
    def running?
      state == RUNNING
    end
    
    def initialize(server, daemon_number)
      @server = server
      @daemon_number = daemon_number
      @thread = Thread.new do
        logger.info "Running thread"
        while(running?)
          #queue.receive()
          sleep(10)
        end
        logger.info "Existing thread"
      end
    end
  end
end