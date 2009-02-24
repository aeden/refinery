module Refinery #:nodoc:
  # Publish events.
  class EventPublisher
    include Refinery::Loggable
    include Refinery::Configurable
    
    #:nodoc:
    RUNNING = 'running'
    #:nodoc:
    STOPPED = 'stopped'
    
    # Initialize the event publisher
    #
    # Options:
    # * <tt>:debug</tt>: Set to true to enable debug logging
    # * <tt>:config</tt>: Provide a file path to load that config
    def initialize(options={})
      logger.level = Logger::DEBUG if options[:debug]
      config.load_file(options[:config]) if options[:config]
    end
    
    # Get the event publisher state
    def state
      @state ||= RUNNING
    end
    
    # Return true if the event publisher is running
    def running?
      state == RUNNING
    end
    
    # A hash of all publishers instantiated.
    def publishers
      @publishers ||= {}
    end
    
    # Run the event publisher
    def run
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
      logger.info "Creating publisher for #{key}"
      queue = sqs.queue(key)
      threads << Thread.new(queue, settings) do |queue, settings|
        while(running?)
          source_file = File.dirname(__FILE__) + "/../../publishers/#{key}.rb"
          if File.exist?(source_file)
            modified_at = File.mtime(source_file)
            if publishers[key] != modified_at
              logger.debug "Loading #{source_file}"
              load(source_file)
              publishers[key] = modified_at
            end
            logger.info "Publish event to queue"
            Object.const_get(camelize(key)).new(queue).execute
            logger.info "Sleeping #{settings['delay']} seconds"
            sleep settings['delay']
          else
            raise SourceFileNotFound, "Source file not found: #{source_file}"
          end
        end
      end
    end
    
    # Get an SQS connection
    def sqs
      @sqs ||= RightAws::SqsGen2.new(
        config['aws']['credentials']["access_key_id"], 
        config['aws']['credentials']["secret_access_key"]
      )
    end
    
    # Camelize the given word.
    def camelize(word, first_letter_in_uppercase = true)
      if first_letter_in_uppercase
        word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
      else
        word.first.downcase + camelize(word)[1..-1]
      end
    end
    
  end
end