class Sample < Refinery::Publisher
  def execute
    publish(['execute', {'something' => true}])
  end
end