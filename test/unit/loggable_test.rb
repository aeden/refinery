require 'test_helper'

class LogMe
  include Refinery::Loggable
end
class LoggableTest < Test::Unit::TestCase
  context "a class with Loggable mixed in" do
    should "have a logger" do
      assert_not_nil LogMe.new.logger
    end
  end
end