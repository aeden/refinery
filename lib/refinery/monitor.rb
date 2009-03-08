module Refinery #:nodoc:
  # The monitor is responsible for monitoring the health of the various
  # components of refinery.
  class Monitor
    include Refinery::Loggable
    include Refinery::Configurable
    include Refinery::Queueable
    include Refinery::Utilities
    
    def initialize(options)
      logger.level = Logger::DEBUG if options[:debug]
      config.load_file(options[:config]) if options[:config]
    end
    
    def run
      logger.info "Starting up monitor"
      heartbeat_monitor_thread = run_heartbeat_monitor
      done_monitor_threads = run_done_monitors
      error_monitor_threads = run_error_monitors
      
      logger.info "Monitor running"
      
      heartbeat_monitor_thread.join
      done_monitor_threads.each { |t| t.join }
      error_monitor_threads.each { |t| t.join }
      logger.info "Shutting down monitor"
    end
    
    private
    
    def run_heartbeat_monitor
      logger.info "Starting heartbeat monitor"
      Thread.new(queue('heartbeat')) do |heartbeat_queue|
        loop do
          while (message = heartbeat_queue.receive)
            logger.debug decode_message(message.body).inspect
            message.delete()
          end
          sleep(5)
        end
      end
    end
    
    def run_done_monitors
      config['processors'].collect do |key, settings|
        queue_name = settings['queue'] || key
        done_queue_name = "#{queue_name}_done"
        logger.debug "Starting monitor for queue #{done_queue_name}"
        Thread.new(queue(done_queue_name)) do |done_queue|
          loop do
            while (message = done_queue.receive)
              done_message = decode_message(message.body)
              logger.debug "Done: #{done_message.inspect}"
              logger.debug "Original message: #{decode_message(done_message['original']).inspect}"
              message.delete()
            end
            sleep(5)
          end
        end
      end
    end
    
    def run_error_monitors
      config['processors'].collect do |key, settings|
        queue_name = settings['queue'] || key
        error_queue_name = "#{queue_name}_error"
        logger.info "Starting error monitor for queue #{error_queue_name}"
        Thread.new(queue(error_queue_name)) do |error_queue|
          loop do
            while (message = error_queue.receive)
              error_message = decode_message(message.body)
              logger.debug "Error: #{error_message.inspect}"
              logger.debug "Original message: #{decode_message(error_message['original']).inspect}"
              message.delete()
            end
            sleep(5)
          end
        end
      end
    end
    
  end
end