module Refinery #:nodoc:
  # A daemon provides a thread to run workers in.
  class Daemon < Thread
    include Refinery::Loggable
    include Refinery::Configurable
    include Refinery::Utilities
    include Refinery::Queueable
    
    RUNNING = 'running'
    STOPPED = 'stopped'
    
    # The name of the daemon
    attr_reader :name
    # The settings for the daemon
    attr_reader :settings
    # The base queue name
    attr_reader :queue_name
    
    # Stop the daemon
    def stop
      self.state = STOPPED
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
    # * <tt>processor</tt>: The processor instance
    # * <tt>name</tt>: The processor name
    # * <tt>waiting_queue</tt>: The waiting queue that provides messages to be processed
    # * <tt>error_queue</tt>: The queue where errors are posted.
    # * <tt>done_queue</tt>: The queue for messages that have been processed.
    # * <tt>settings</tt>: The settings hash from the config.
    #
    # The settings hash may contain the following options:
    # * <tt>visibility</tt>: The time in seconds that the message is hidden
    # in the queue.
    def initialize(processor, name, queue_prefix='', settings={})
      logger.debug "Starting daemon"
      
      @processor = processor
      @name = name
      @settings = settings
      
      queue_name = settings['queue'] || name
      queue_name = "#{queue_prefix}#{queue_name}"
      logger.debug "Using queue #{queue_name}"
      @queue_name = queue_name
      
      super do
        begin
          execute
        rescue Exception => e
          logger.error e
        end
      end
    end
    
    private
    def execute
      logger.debug "Running daemon thread: #{name} (settings: #{settings.inspect})"
      
      begin
        require 'java'
        java.lang.Thread.current_thread.name = "#{name} Daemon"
      rescue LoadError => e
      end
      
      while(running?)
        #logger.debug "Checking #{queue_name}_waiting"
        with_queue("#{queue_name}_waiting") do |waiting_queue|
          while (message = waiting_queue.receive(settings['visibility']))
            worker = load_worker_class(name).new(self)
            begin
              result, run_time = worker.run(decode_message(message.body))
              if result
                with_queue("#{queue_name}_done") do |done_queue|
                  done_message = {
                    'host_info' => host_info,
                    'original' => message.body,
                    'run_time' => run_time
                  }
                  logger.debug "Sending 'done' message to #{done_queue.name}"
                  done_queue.send_message(encode_message(done_message))
                end
              
                logger.debug "Deleting message from queue"
                message.delete()
              end
            rescue Exception => e
              with_queue("#{queue_name}_error") do |error_queue|
                error_message = {
                  'error' => {
                    'message' => e.message, 
                    'class' => e.class.name,
                    'backtrace' => e.backtrace
                  }, 
                  'host_info' => host_info,
                  'original' => message.body
                }
                logger.error "Sending 'error' message to #{error_queue.name}: #{e.message}"
                error_queue.send_message(encode_message(error_message))
              end
              message.delete()
            end
          end
          sleep(settings['sleep'] || 5)
        end
      end
      logger.debug "Exiting daemon thread"
    end
    
    # A hash of worker classes
    def workers
      @workers ||= {}
    end
    
    private
    # Load the appropriate worker class
    def load_worker_class(name)
      source_file = "#{@processor.server.workers_directory}/#{name}.rb"
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
      
      Object.const_get(camelize("#{name}_worker"))
    end
  end
end