module Refinery #:nodoc:
  # The monitor is responsible for monitoring the health of the various
  # components of refinery.
  class Monitor
    include Refinery::Loggable
    include Refinery::Configurable
    include Refinery::Queueable
    include Refinery::Utilities
    
    # Initialize the monitor.
    #
    # Options:
    # * <tt>:verbose</tt>: Enable INFO level logging
    # * <tt>:debug</tt>: Enable DEBUG level logging
    # * <tt>:config</tt>: The config file
    def initialize(options)
      logger.level = Logger::INFO if options[:verbose]
      logger.level = Logger::DEBUG if options[:debug]
      config.load_file(options[:config]) if options[:config]
      @queue_prefix = config['prefix'] || ''
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
      logger.info "Starting #{@queue_prefix}heartbeat monitor"
      Thread.new("#{@queue_prefix}heartbeat") do |heartbeat_queue_name|
        loop do
          with_queue(heartbeat_queue_name) do |heartbeat_queue|
            while (message = heartbeat_queue.receive)
              logger.debug "#{heartbeat_queue.name}: #{decode_message(message.body).inspect}"
              message.delete()
            end
          end
          sleep(5)
        end
      end
    end
    
    def run_done_monitors
      config['processors'].collect do |key, settings|
        queue_name = settings['queue'] || key
        done_queue_name = "#{@queue_prefix}#{queue_name}_done"
        logger.debug "Starting monitor for queue #{done_queue_name}"
        Thread.new(done_queue_name) do |done_queue_name|
          loop do
            with_queue(done_queue_name) do |done_queue|
              while (message = done_queue.receive)
                done_message = decode_message(message.body)
                logger.debug "#{done_queue.name}: #{done_message.pretty_inspect}"
                processed = decode_message(done_message['original'])
                logger.info "Done: #{queue_name} #{processed.inspect}"
                message.delete()
                statistics.record_done(done_message)
              end
              sleep(5)
            end
          end
        end
      end
    end
    
    def run_error_monitors
      config['processors'].collect do |key, settings|
        queue_name = settings['queue'] || key
        error_queue_name = "#{@queue_prefix}#{queue_name}_error"
        logger.info "Starting error monitor for queue #{error_queue_name}"
        Thread.new(error_queue_name) do |error_queue_name|
          loop do
            with_queue(error_queue_name) do |error_queue|
              while (message = error_queue.receive)
                error_message = decode_message(message.body)
                logger.debug "#{error_queue.name}: #{error_message.pretty_inspect}"
                processed = decode_message(error_message['original'])
                logger.info "Error: #{queue_name} #{processed.inspect}"
                message.delete()
                statistics.record_error(error_message)
              end
            end
            sleep(5)
          end
        end
      end
    end
    
  end
end