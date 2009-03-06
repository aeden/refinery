module Refinery #:nodoc:
  # A daemon provides a thread to run workers in.
  class Daemon
    include Refinery::Loggable
    include Refinery::Configurable
    include Refinery::Utilities
    
    RUNNING = 'running'
    STOPPED = 'stopped'
    
    attr_reader :thread
    attr_reader :waiting_queue
    attr_reader :done_queue
    attr_reader :error_queue
    
    # Stop the daemon
    def stop
      state = STOPPED
    end
    
    # Return the daemon state
    def state
      @state ||= RUNNING
    end
    
    # Set the daemon state.
    def state=(state)
      @state = state
    end
    protected :state
    
    # Return true if the daemon state is running.
    def running?
      state == RUNNING
    end
    
    # Initialize the daemon.
    #
    # * <tt>server</tt>: The server instance
    # * <tt>key</tt>: The processor key (i.e. its name)
    # * <tt>waiting_queue</tt>: The waiting queue that provides messages to be processed
    # * <tt>error_queue</tt>: The queue where errors are posted.
    # * <tt>done_queue</tt>: The queue for messages that have been processed.
    def initialize(server, key, waiting_queue, error_queue, done_queue)
      Refinery::Server.logger.info "Starting daemon"
      
      @server = server
      @waiting_queue = waiting_queue
      @error_queue = error_queue
      @done_queue = done_queue
      
      @thread = Thread.new(self) do |daemon|
        logger.info "Running daemon thread"
        while(running?)
          daemon.waiting_queue.receive_messages(1, 10).each do |message|
            worker = load_worker_class(key).new(self)
            begin
              message.delete() if worker.run(JSON.parse(Base64.decode64(message.body)))
            rescue Exception => e
              error_message = {
                'error' => {'message' => e.message, 'class' => e.class.name}, 
                'original' => message
              }
              error_queue.send_message(Base64.encode64(error_message.to_json))
              message.delete()
            end
          end
          sleep(1)
        end
        logger.info "Exiting daemon thread"
      end
    end
    
    # A hash of worker classes
    def workers
      @workers ||= {}
    end
    
    private
    def load_worker_class(key)
      source_file = "#{@server.workers_directory}/#{key}.rb"
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