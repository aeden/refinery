# An example publisher that posts a message to the queue that should raise an error.
class Error < Refinery::Publisher
  def execute
    if waiting_queue.size == 0
      publish(['execute', {'text' => 'fire an error, please'}])
    end
  end
end