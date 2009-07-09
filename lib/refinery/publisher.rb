module Refinery #:nodoc:
  # Base class for publishers to be implemented by subclasses.
  class Publisher
    include Refinery::Loggable
    include Refinery::Queueable
    
    # Initialize the publisher with the queue to publish messages to.
    def initialize(waiting_queue_name)
      @waiting_queue_name = waiting_queue_name
    end
    
    protected
    # Get the publish queue name
    def waiting_queue_name
      @waiting_queue_name
    end
    
    # Publish the message. The message will be converted to JSON and pushed
    # into the queue associated with the publisher.
    def publish(message)
      with_queue(waiting_queue_name) do |waiting_queue|
        logger.debug "Publisher #{self.class.name} sending message: #{message.to_json}"
        waiting_queue.send_message(Base64.encode64(message.to_json))
      end
    end
  end
end