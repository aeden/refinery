module RJob
  class Daemon
    include RJob::Loggable
    
    def self.start(daemon_number, server)
      RJob::Server.logger.info "Starting daemon"
    end
  end
end