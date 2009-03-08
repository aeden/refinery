class Sleep < Refinery::Worker
  def execute(message)
    logger.info "received message: #{message.inspect}"
    sleep(message['seconds'])
    return true
  end
end