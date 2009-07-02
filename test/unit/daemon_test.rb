require File.dirname(__FILE__) + '/../test_helper'
class DaemonTest < Test::Unit::TestCase
  context "a daemon" do
    setup do
      @server = stub('Server')
      @waiting_queue = stub('Queue(waiting)')
      @error_queue = stub('Queue(error)')
      @done_queue = stub('Queue(done)')
    end
    should "be startable" do
      @waiting_queue.stubs(:receive)
      assert_nothing_raised do
        daemon = Refinery::Daemon.new(@server, 'sample', @waiting_queue, @error_queue, @done_queue)
      end
    end
    should "have logging" do
      @waiting_queue.stubs(:receive)
      daemon = Refinery::Daemon.new(@server, 'sample', @waiting_queue, @error_queue, @done_queue)
      assert_not_nil daemon.logger
    end
    should "allow visibility setting" do
      @waiting_queue.expects(:receive).with(600)
      daemon = Refinery::Daemon.new(@server, 'sample', @waiting_queue, @error_queue, @done_queue, {'visibility' => 600})
    end
    context "that is started" do
      setup do
        @waiting_queue.stubs(:receive)
        @daemon = Refinery::Daemon.new(@server, 'sample', @waiting_queue, @error_queue, @done_queue)
      end
      should "have a state of running" do
        assert @daemon.running?
      end
      context "after calling stop" do
        setup do
          @daemon.stop
        end
        should "not be running" do
          assert !@daemon.running?
        end
      end
    end
  end
end