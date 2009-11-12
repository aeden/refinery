module Refinery #:nodoc:
  # A queue provider for beanstalk
  class BeanstalkQueueProvider
    include Refinery::Loggable
    
    attr_reader :queues
    
    # Initialize the queue provider
    def initialize(hosts=nil)
      @hosts = hosts
      @queues = {}
    end
    # Get the named queue
    def queue(name)
      queues[name] ||= Refinery::BeanstalkQueue.new(name, @hosts)
    end
  end
end