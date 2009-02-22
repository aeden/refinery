module RJob
  class Heartbeat
    include RJob::Loggable
    include RJob::Configurable
    def initialize(server)
      @server = server
      @thread = Thread.new do
        loop do
          logger.info "send heartbeat, #{@server.daemons.length} daemons"
          sleep(10)
        end
      end
    end
  end
end