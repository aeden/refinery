module RJob
  class Server
    def self.logger
      @logger ||= begin
        logger = Logger.new(File.dirname(__FILE__) + '/../../logs/server.log')
        logger.level = Logger::DEBUG
        logger
      end
    end
    def self.start
      logger.info "Starting RJob server"
    end
  end
end