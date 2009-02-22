module RJob
  class EventPublisher
    include RJob::Loggable
    include RJob::Configurable
    
    def initialize(options={})
      
    end
    
    def run
      logger.info "Starting event publisher"
      queue = sqs.queue('events')
    end
    
    def sqs
      @sqs ||= RightAws::SqsGen2.new(
        config.aws.credentials["access_key_id"], 
        config.aws.credentials["secret_access_key"]
      )
    end
  end
end