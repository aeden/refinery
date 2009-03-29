module Refinery #:nodoc:
  # A heartbeat publisher that indicates a server is alive.
  class Heartbeat
    include Refinery::Loggable
    include Refinery::Configurable
    include Refinery::Queueable
    include Refinery::Utilities
    
    # Initialize the heartbeat for the given server.
    def initialize(server)
      @server = server
      @thread = Thread.new(queue('heartbeat')) do |heartbeat_queue|
        loop do
          begin
            logger.debug "Send heartbeat"
            message = {
              'host_info' => host_info,
              'timestamp' => Time.now.utc,
              'running_daemons' => @server.daemons.length
            }
            heartbeat_queue.send_message(Base64.encode64(message.to_json))
            sleep(60)
          rescue Exception => e
            logger.error "Error sending heartbeat: #{e.message}"
          end
        end
      end
    end
  end
end