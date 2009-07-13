class SleepPublisher < Refinery::Publisher
  def execute
    publish({'seconds' => rand(5) + 0.5})
  end
end