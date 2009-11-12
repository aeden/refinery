module Refinery #:nodoc:
  # An interface to beanstalk using SQS-compatible methods.
  class BeanstalkQueue
    include Refinery::Loggable
    attr_reader :name
    
    # Construct a BeanstalkQueue instance.
    #
    # *<tt>name</tt>: if specified then that "tube" will be used.
    # *<tt>host</tt>: if specified then those host:port combos will be used.
    def initialize(name=nil, hosts=nil)
      @name = name.gsub(/_/, '-') # beanstalk does not like underscores in tube names
      @hosts = hosts || ['localhost:11300']
    end
    
    # Get the next message from the queue
    def receive(visibility=nil)
      beanstalk.reserve(visibility)
    end
    
    # Get the approximate queue size
    def size
      beanstalk.stats_tube(name)['current-jobs-ready']
    end
    
    # Send a message
    def send_message(message)
      beanstalk.put(message)
    end
    
    protected
    def beanstalk
      @beanstalk ||= Beanstalk::Pool.new(@hosts, name)
    end
  end
end