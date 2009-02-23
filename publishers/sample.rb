class Sample < RJob::Publisher
  def execute
    publish(['execute', {'something' => true}])
  end
end