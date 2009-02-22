require File.dirname(__FILE__) + '/../test_helper'
class EventPublisherTest < Test::Unit::TestCase
  context "an event publisher" do
    should "raise an error if credentials are not set" do
      event_publisher = RJob::EventPublisher.new
      assert_raise RJob::ConfigurationError do
        event_publisher.run
      end
    end
  end
end