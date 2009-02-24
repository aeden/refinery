require File.dirname(__FILE__) + '/../test_helper'
class DaemonTest < Test::Unit::TestCase
  context "a daemon" do
    setup do
      @server = stub('Server')
      @queue = stub('Queue')
    end
    should "be startable" do
      assert_nothing_raised do
        daemon = Refinery::Daemon.new(@server, 'sample', @queue)
      end
    end
    should "have logging" do
      daemon = Refinery::Daemon.new(@server, 'sample', @queue)
      assert_not_nil daemon.logger
    end
    context "that is started" do
      setup do
        @daemon = Refinery::Daemon.new(@server, 'sample', @queue)
      end
      should "have a state of running" do
        assert @daemon.running?
      end
    end
  end
end