module Refinery #:nodoc:
  # The server instance provides a runtime environment for daemons.
  # To start the server create an Refinery::Server instance and invole run.
  class Server
    include Refinery::Loggable
    include Refinery::Configurable
    include Refinery::Queueable
    include Refinery::Utilities
    
    attr_accessor :workers_directory
    
    # Get a server-wide logger
    def self.logger
      @logger ||= begin
        logger = Logger.new(STDOUT || log_to)
        logger.level = Logger::ERROR
        logger
      end
    end
    
    # Initialize the server.
    #
    # Options:
    # * <tt>:debug</tt>: Set to true to enable debug logging
    # * <tt>:config</tt>: Provide a file path to load that config
    def initialize(options={})
      logger.level = Logger::DEBUG if options[:debug]
      config.load_file(options[:config]) if options[:config]
      workers_directory = options[:workers] if options[:workers]
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
      config['processors'].each do |key, settings|
        logger.info "Creating daemons for #{key}"
        queue_name = settings['queue'] || key
        logger.debug "Using queue #{queue_name}"
        queue = sqs.queue(queue_name)
        1.upto(settings['workers']['initial']) do
          daemons << Refinery::Daemon.new(self, key, queue)
        end
        logger.info "Running #{daemons.length} daemons"
      end
      
      Heartbeat.new(self)
      
      begin
        daemons.each { |daemon| daemon.thread.join }
      rescue Interrupt => e
      end
    end
    
    def log_to
      File.dirname(__FILE__) + '/../../logs/server.log'
    end
  end
end
