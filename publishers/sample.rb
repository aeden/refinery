# A sample publisher that posts a message to the queue.
class SamplePublisher < Refinery::Publisher
  def execute
    publish_if_empty({'text' => 'hey there!'})
  end
end