class Sleep < Refinery::Publisher
  def execute
    if waiting_queue.size == 0
      publish({'seconds' => 5})
    end
  end
end