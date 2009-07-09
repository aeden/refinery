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
        logger.formatter = CustomFormatter.new
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
      queue_prefix = config['prefix'] || ''
      config['processors'].each do |key, settings|
        logger.debug "Creating daemons for #{key}"
        1.upto(settings['workers']['initial']) do
          daemons << Refinery::Daemon.new(self, key, queue_prefix, settings)
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
  
  class CustomFormatter
    def format
      @format ||= "%s, [%s#%d][%s] %5s -- %s: %s\n"
    end
    def call(severity, time, progname, msg)
      format % [severity[0..0], format_datetime(time), $$, Thread.current.object_id.to_s, severity, progname, msg.to_s]
    end
    def format_datetime(time)
      time.strftime("%Y-%m-%dT%H:%M:%S.") << "%06d " % time.usec
    end
  end
end
