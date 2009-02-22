require File.dirname(__FILE__) + '/../test_helper'
class ServerTest < Test::Unit::TestCase
  context "the server class" do
    should "provide a logger" do
      assert_not_nil RJob::Server.logger
    end
    context "logger" do
      should "default to DEBUG level" do
        assert_equal Logger::DEBUG, RJob::Server.logger.level
      end
    end
  end
end