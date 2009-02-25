# This is an example worker that raises an error.
class Error < Refinery::Worker
  # Execute the work once.
  def execute(message)
    logger.info "received message: #{message.inspect}"
    raise RuntimeError, "processing failure example"
  end
end