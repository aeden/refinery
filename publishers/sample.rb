# A sample publisher that posts a message to the queue.
class Sample < Refinery::Publisher
  def execute
    if waiting_queue.size == 0
      publish(['execute', {'text' => 'hey there!'}])
    end
  end
end