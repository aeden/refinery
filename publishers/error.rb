# An example publisher that posts a message to the queue that should raise an error.
class ErrorPublisher < Refinery::Publisher
  def execute
    publish_if_empty({'text' => 'fire an error, please'})
  end
end