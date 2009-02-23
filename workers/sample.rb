# This is a sample worker.
class SampleWorker < RJob::Worker
  # Execute the work once.
  def execute(message)
    logger.info "received message: #{message}"
  end
end