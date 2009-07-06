module Refinery #:nodoc:
  # Publish events.
  class EventPublisher
    include Refinery::Loggable
    include Refinery::Configurable
    include Refinery::Queueable
    include Refinery::Utilities
    
    STARTING = 'starting' #:nodoc:
    RUNNING = 'running' #:nodoc:
    STOPPED = 'stopped' #:nodoc:
    
    attr_accessor :publishers_directory
    
    # Initialize the event publisher
    #
    # Options:
    # * <tt>:debug</tt>: Set to true to enable debug logging
    # * <tt>:config</tt>: Provide a file path to load that config
    def initialize(options={})
      logger.level = Logger::INFO if options[:verbose]
      logger.level = Logger::DEBUG if options[:debug]
      config.load_file(options[:config]) if options[:config]
      self.publishers_directory = options[:publishers] if options[:publishers]
    end
    
    # Get the event publisher state
    def state
      @state ||= STARTING
    end
    
    # Return true if the event publisher is running
    def running?
      state == RUNNING
    end
    
    # The directory where publishers are found. Defaults to ./publishers
    def publishers_directory
      @publishers_directory ||= './publishers'
    end
    
    # A hash of all publisher classes mapped to last modified timestamps.
    def publishers
      @publishers ||= {}
    end
    
    # Run the specified publisher once and return
    def run_once(key)
      prefix = config['prefix'] || ''
      settings = config['processors'][key]
      raise RuntimeError, "No processor configuration found for #{key}" unless settings
      queue_name = settings['queue'] || key
      queue_name = "#{prefix}#{queue_name}"
      logger.debug "Using queue #{queue_name}_waiting"
      waiting_queue = queue("#{queue_name}_waiting")
      load_publisher_class(key).new(waiting_queue).execute
    end
    
    # Run the event publisher
    def run
      @state = RUNNING
      logger.info "Starting event publisher"
      config['processors'].each do |key, settings|
        run_publisher(key, settings)
      end
      
      begin
        threads.each { |thread| thread.join }
      rescue Interrupt => e
      end
      
      logger.info "Exiting event publisher"
    end
    
    private
    # An array of threads, one for each publisher instance
    def threads
      @threads ||= []
    end
    
    # Run the publisher for the given key
    def run_publisher(key, settings)
      if File.exists?(source_file(key))
        prefix = config['prefix'] || ''
        logger.info "Creating publisher for #{key}"
        queue_name = settings['queue'] || key
        queue_name = "#{prefix}#{queue_name}"
        logger.debug "Using queue #{queue_name}_waiting"
        waiting_queue = queue("#{queue_name}_waiting")
      
        threads << Thread.new(waiting_queue, settings) do |waiting_queue, settings|
          while(running?)
            begin
              load_publisher_class(key).new(waiting_queue).execute
            rescue Exception => e
              logger.error e
              raise e
            end
          
            delay = settings['publishers']['delay'] || 60
            logger.debug "Sleeping #{delay} seconds"
            sleep delay
          
          end
        end
      else
        logger.warn "No publisher found for #{key}"
      end
    end
    
    def source_file(key)
      source_file = "#{publishers_directory}/#{key}.rb"
    end
    
    def load_publisher_class(key)
      source_file = source_file(key)
      if File.exist?(source_file)
        modified_at = File.mtime(source_file)
        if publishers[key] != modified_at
          logger.debug "Loading #{source_file}"
          load(source_file)
          publishers[key] = modified_at
        end
      else
        raise SourceFileNotFound, "Source file not found: #{source_file}"
      end
      
      Object.const_get(camelize("#{key}_publisher"))
    end
    
  end
end