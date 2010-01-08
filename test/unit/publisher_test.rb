require 'test_helper'

class SamplePublisher < Refinery::Publisher
end

class PublisherTest < Test::Unit::TestCase
  context "a publisher" do
    should "be instantiable" do
      waiting_queue = stub('waiting queue')
      SamplePublisher.new(waiting_queue)
    end
  end
end