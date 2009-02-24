module Refinery
  module Queueable
    # Get an SQS connection
    def sqs
      @sqs ||= RightAws::SqsGen2.new(
        config['aws']['credentials']["access_key_id"], 
        config['aws']['credentials']["secret_access_key"],
        {:multi_thread => true}
      )
    end
  end
end