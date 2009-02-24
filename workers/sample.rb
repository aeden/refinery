# This is a sample worker.
class Sample < Refinery::Worker
  # Execute the work once.
  def execute(message)
    logger.info "received message: #{message.inspect}"
  end
end