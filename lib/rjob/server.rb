module RJob
  class Server
    include RJob::Loggable
    def self.logger
      @logger ||= begin
        logger = Logger.new(File.dirname(__FILE__) + '/../../logs/server.log')
        logger.level = Logger::DEBUG
        logger
      end
    end
    def self.start
      logger.info "Starting RJob server"
      new.run
    end

    def config
      @config ||= RJob::Config.new
    end

    def run
      1.upto(config.initial_number_of_daemons) do |daemon_number|
        RJob::Daemon.start(daemon_number, self)
      end
    end
  end
end
