module Refinery #:nodoc:
  # Base class for publishers to be implemented by subclasses.
  class Publisher
    include Refinery::Loggable
    
    # Initialize the publisher
    def initialize(waiting_queue)
      @waiting_queue = waiting_queue
    end
    
    protected
    # Get the publish queue
    def waiting_queue
      @waiting_queue
    end
    
    # Publish the message. The message will be converted to JSON and pushed
    # into the queue associated with the publisher.
    def publish(message)
      logger.debug "Message: #{message.to_json}"
      waiting_queue.send_message(Base64.encode64(message.to_json))
    end
  end
end