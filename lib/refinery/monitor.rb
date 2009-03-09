module Refinery #:nodoc:
  # The monitor is responsible for monitoring the health of the various
  # components of refinery.
  class Monitor
    include Refinery::Loggable
    include Refinery::Configurable
    include Refinery::Queueable
    include Refinery::Utilities
    
    def initialize(options)
      logger.level = Logger::INFO if options[:verbose]
      logger.level = Logger::DEBUG if options[:debug]
      config.load_file(options[:config]) if options[:config]
    end
    
    # Execute the monitor. The monitor will start one heartbeat 
    # monitor thread and one thread for each done queue and error
    # queue as specified in the configuration.
    def run
      logger.info "Starting up monitor"
      heartbeat_monitor_thread = run_heartbeat_monitor
      done_monitor_threads = run_done_monitors
      error_monitor_threads = run_error_monitors
      
      logger.info "Monitor running"
      
      Refinery::StatsServer.new.run
      
      begin
        heartbeat_monitor_thread.join
        done_monitor_threads.each { |t| t.join }
        error_monitor_threads.each { |t| t.join }
      rescue Interrupt => e
      end
      
      logger.info "Monitor is exiting"
    end
    
    private
    def statistics
      @statistics ||= Refinery::Statistics.new
    end
    
    def run_heartbeat_monitor
      logger.info "Starting heartbeat monitor"
      Thread.new(queue('heartbeat')) do |heartbeat_queue|
        loop do
          begin
            while (message = heartbeat_queue.receive)
              logger.debug decode_message(message.body).inspect
              message.delete()
            end
          rescue Exception => e
            logger.error e
          end
          sleep(2)
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
            begin
              while (message = done_queue.receive)
                done_message = decode_message(message.body)
                processed = decode_message(done_message['original'])
                logger.info "Done: #{processed.inspect}"
                message.delete()
                statistics.record_done(done_message)
              end
            rescue Exception => e
              logger.error e
            end
            sleep(2)
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
            begin
              while (message = error_queue.receive)
                error_message = decode_message(message.body)
                processed = decode_message(error_message['original'])
                logger.info "Error: #{processed.inspect}"
                message.delete()
                statistics.record_error(error_message)
              end
            rescue Exception => e
              logger.error e
            end
            sleep(2)
          end
        end
      end
    end
    
  end
end