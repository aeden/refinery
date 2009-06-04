# A sample publisher that posts a message to the queue.
class SamplePublisher < Refinery::Publisher
  def execute
    if waiting_queue.size == 0
      publish({'text' => 'hey there!'})
    end
  end
end