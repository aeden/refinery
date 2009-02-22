require File.dirname(__FILE__) + '/../test_helper'
class DaemonTest < Test::Unit::TestCase
  context "a daemon" do
    setup do
      @server = stub('Server')
    end
    should "be startable" do
      assert_nothing_raised do
        daemon = RJob::Daemon.start(@server, 1)
      end
    end
    should "have logging" do
      daemon = RJob::Daemon.start(@server, 1)
      assert_not_nil daemon.logger
    end
    context "that is started" do
      setup do
        @daemon = RJob::Daemon.start(@server, 1)
      end
      should "have a state of running" do
        assert_equal RJob::Daemon::RUNNING, @daemon.state
      end
    end
  end
end