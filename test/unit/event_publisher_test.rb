require 'test_helper'

class EventPublisherTest < Test::Unit::TestCase
  context "an event publisher" do
    should "raise an error if credentials are not set" do
      publishing_settings = {'sample' => {'delay' => 10}}
      Refinery::Config.any_instance.stubs(:publishing).returns(publishing_settings)
      event_publisher = Refinery::EventPublisher.new
      event_publisher.run
    end
  end
end