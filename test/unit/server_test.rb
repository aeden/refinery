require File.dirname(__FILE__) + '/../test_helper'
class ServerTest < Test::Unit::TestCase
  context "the server class" do
    should "provide a logger" do
      assert_not_nil RJob::Server.logger
    end
    context "logger" do
      should "default to ERROR level" do
        assert_equal Logger::ERROR, RJob::Server.logger.level
      end
    end
  end
  context "a server instance" do
    setup do
      @server = RJob::Server.new
    end
    should "have a config" do
      assert_not_nil @server.config
    end
    should "be runnable" do
      assert_nothing_raised do
        thread = Thread.new do
          @server.run
        end
        @server.stop
      end
    end
  end
end