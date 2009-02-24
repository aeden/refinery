module Refinery
  class Daemon
    include Refinery::Loggable
    include Refinery::Configurable
    include Refinery::Utilities
    
    RUNNING = 'running'
    STOPPED = 'stopped'
    
    attr_reader :thread
    attr_reader :queue
    
    # Stop the daemon
    def stop
      state = STOPPED
    end
    
    # Return the daemon state
    def state
      @state ||= RUNNING
    end
    
    def state=(state)
      @state = state
    end
    protected :state
    
    # Return true if the daemon state is running.
    def running?
      state == RUNNING
    end
    
    def initialize(server, key, queue)
      Refinery::Server.logger.info "Starting daemon"
      @server = server
      @queue = queue
      @thread = Thread.new(self) do |daemon|
        logger.info "Running thread"
        while(running?)
          while(message = daemon.queue.receive())
            worker = load_worker_class(key).new
            worker.run(JSON.parse(Base64.decode64(message.body)))
          end
          sleep(10)
        end
        logger.info "Exiting thread"
      end
    end
    
    def workers
      @workers ||= {}
    end
    
    private
    def load_worker_class(key)
      source_file = File.dirname(__FILE__) + "/../../workers/#{key}.rb"
      if File.exist?(source_file)
        modified_at = File.mtime(source_file)
        if workers[key] != modified_at
          logger.debug "Loading #{source_file}"
          load(source_file)
          workers[key] = modified_at
        end
      else
        raise SourceFileNotFound, "Source file not found: #{source_file}"
      end
      
      Object.const_get(camelize(key))
    end
  end
end