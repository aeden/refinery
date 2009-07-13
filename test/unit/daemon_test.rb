require File.dirname(__FILE__) + '/../test_helper'
class DaemonTest < Test::Unit::TestCase
  context "a daemon" do
    setup do
      @server = stub('Server')
      @processor = stub('Processor', :server => @server)
      
      @waiting_queue = stub('Queue(waiting)')
      @error_queue = stub('Queue(error)')
      @done_queue = stub('Queue(done)')
      
      Refinery::Daemon.any_instance.stubs(:queue).with(
      'sample_waiting').returns(@waiting_queue)
      Refinery::Daemon.any_instance.stubs(:queue).with(
      'sample_error').returns(@error_queue)
      Refinery::Daemon.any_instance.stubs(:queue).with(
      'sample_done').returns(@done_queue)
    end
    should "be startable" do
      @waiting_queue.stubs(:receive)
      assert_nothing_raised do
        daemon = Refinery::Daemon.new(@processor, 'sample')
      end
    end
    should "have logging" do
      @waiting_queue.stubs(:receive)
      daemon = Refinery::Daemon.new(@processor, 'sample')
      assert_not_nil daemon.logger
    end
    should "allow visibility setting" do
      @waiting_queue.expects(:receive).with(600)
      daemon = Refinery::Daemon.new(@processor, 'sample', '', {'visibility' => 600})
    end
    should "have a queue name" do
      @waiting_queue.stubs(:receive)
      Refinery::Daemon.any_instance.expects(:queue).with(
      'prefix_sample_waiting').returns(@waiting_queue)
      daemon = Refinery::Daemon.new(@processor, 'sample', 'prefix_')
      assert_equal 'prefix_sample', daemon.queue_name
    end
    context "that is started" do
      setup do
        @waiting_queue.stubs(:receive)
        @daemon = Refinery::Daemon.new(@processor, 'sample')
      end
      should "have a state of running" do
        assert @daemon.running?
      end
#       context "after calling stop" do
#         setup do
#           @daemon.stop
#         end
#         should "not be running" do
#           assert !@daemon.running?
#         end
#       end
    end
  end
end