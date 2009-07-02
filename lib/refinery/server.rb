module Refinery #:nodoc:
  # The server instance provides a runtime environment for daemons.
  # To start the server create an Refinery::Server instance and invoke run.
  class Server
    include Refinery::Loggable
    include Refinery::Configurable
    include Refinery::Queueable
    include Refinery::Utilities
    
    # The directory where worker source files are stored. Defaults to
    # ./workers
    attr_accessor :workers_directory
    
    # Get a server-wide logger
    def self.logger
      @logger ||= begin
        logger = Logger.new(STDOUT)
        logger.level = Logger::WARN
        logger
      end
    end
    
    # Initialize the server.
    #
    # Options:
    # * <tt>:config</tt>: Provide a file path to load that config
    # * <tt>:debug</tt>: Set to true to enable debug logging
    # * <tt>:verbose</tt>: Set to true to enable info logging
    # * <tt>:workers</tt>: The workers directory
    def initialize(options={})
      logger.level = Logger::INFO if options[:verbose]
      logger.level = Logger::DEBUG if options[:debug]
      config.load_file(options[:config]) if options[:config]
      self.workers_directory = options[:workers] if options[:workers]
    end
    
    # The directory where workers are found. Defaults to ./workers
    def workers_directory
      @workers_directory ||= "./workers"
    end
    
    # Stop the server
    def stop
      logger.info "Stopping Refinery Server"
      daemons.each { |daemon| daemon.stop }
    end
    
    # An array of all daemons
    def daemons
      @daemons ||= []
    end
    
    # Run the server
    def run
      logger.info "Starting Refinery server"
      execute_daemons
      logger.info "Server is exiting"
    end
    
    private
    def execute_daemons
      prefix = config['prefix'] || ''
      config['processors'].each do |key, settings|
        logger.debug "Creating daemons for #{key}"
        
        queue_name = settings['queue'] || key
        queue_name = "#{prefix}#{queue_name}"
        logger.debug "Using queue #{queue_name}"
        waiting_queue = queue("#{queue_name}_waiting")
        error_queue = queue("#{queue_name}_error")
        done_queue = queue("#{queue_name}_done")
        
        1.upto(settings['workers']['initial']) do
          daemons << Refinery::Daemon.new(self, key, waiting_queue, error_queue, done_queue, settings)
        end
        
        logger.debug "Running #{daemons.length} daemons"
      end
      
      Heartbeat.new(self)
      
      begin
        daemons.each { |daemon| daemon.thread.join }
      rescue Interrupt => e
      end
    end
  end
end
