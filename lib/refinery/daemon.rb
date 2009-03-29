module Refinery #:nodoc:
  # A daemon provides a thread to run workers in.
  class Daemon
    include Refinery::Loggable
    include Refinery::Configurable
    include Refinery::Utilities
    
    RUNNING = 'running'
    STOPPED = 'stopped'
    
    # The daemon's thread
    attr_reader :thread
    # The name of the daemon
    attr_reader :name
    # The queue for incoming messages to process
    attr_reader :waiting_queue
    # The queue for outgoing messages once they've been processed
    attr_reader :done_queue
    # The queue for error messages
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
    # * <tt>name</tt>: The processor name
    # * <tt>waiting_queue</tt>: The waiting queue that provides messages to be processed
    # * <tt>error_queue</tt>: The queue where errors are posted.
    # * <tt>done_queue</tt>: The queue for messages that have been processed.
    def initialize(server, name, waiting_queue, error_queue, done_queue)
      Refinery::Server.logger.debug "Starting daemon"
      
      @server = server
      @name = name
      @waiting_queue = waiting_queue
      @error_queue = error_queue
      @done_queue = done_queue
      
      @thread = Thread.new(self) do |daemon|
        logger.debug "Running daemon thread"
        while(running?)
          begin
            while (message = waiting_queue.receive)
              worker = load_worker_class(name).new(self)
              begin
                result, run_time = worker.run(decode_message(message.body))
                if result
                  done_message = {
                    'host_info' => host_info,
                    'original' => message.body,
                    'run_time' => run_time
                  }
                  logger.debug "Sending 'done' message to #{done_queue.name}"
                  done_queue.send_message(encode_message(done_message))
                
                  logger.debug "Deleting message from queue"
                  message.delete()
                end
              rescue Exception => e
                error_message = {
                  'error' => {
                    'message' => e.message, 
                    'class' => e.class.name
                  }, 
                  'host_info' => host_info,
                  'original' => message.body
                }
                error_queue.send_message(encode_message(error_message))
                message.delete()
              end
            end
            sleep(1)
          rescue Exception => e
            logger.error "An error occurred while receiving from the waiting queue: #{e.message}"
          end
        end
        logger.debug "Exiting daemon thread"
      end
    end
    
    # A hash of worker classes
    def workers
      @workers ||= {}
    end
    
    private
    # Load the appropriate worker class
    def load_worker_class(name)
      source_file = "#{@server.workers_directory}/#{name}.rb"
      if File.exist?(source_file)
        modified_at = File.mtime(source_file)
        if workers[name] != modified_at
          logger.debug "Loading #{source_file}"
          load(source_file)
          workers[name] = modified_at
        end
      else
        raise SourceFileNotFound, "Source file not found: #{source_file}"
      end
      
      Object.const_get(camelize(name))
    end
  end
end