class SleepPublisher < Refinery::Publisher
  def execute
    if waiting_queue.size == 0
      publish({'seconds' => rand(5) + 0.5})
    end
  end
end