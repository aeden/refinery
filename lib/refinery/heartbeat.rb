module Refinery #:nodoc:
  # A heartbeat publisher that indicates a server is alive.
  class Heartbeat
    include Refinery::Loggable
    include Refinery::Configurable
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