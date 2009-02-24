# A sample publisher that posts a message to the queue.
class Sample < Refinery::Publisher
  def execute
    publish(['execute', {'text' => 'hey there!'}])
  end
end