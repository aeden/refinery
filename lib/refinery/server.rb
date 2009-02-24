module Refinery #:nodoc:
  # The server instance provides a runtime environment for daemons.
  # To start the server create an Refinery::Server instance and invole run.
  class Server
    include Refinery::Loggable
    include Refinery::Configurable
    
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
      1.upto(config.initial_number_of_daemons) do |daemon_number|
        daemons << Refinery::Daemon.start(self, daemon_number)
      end
      logger.info "Running #{daemons.length} daemons"
      
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
