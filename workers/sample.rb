# This is a sample worker.
class SampleWorker < Refinery::Worker
  # Execute the work once.
  def execute(message)
    logger.info "received message: #{message}"
  end
end