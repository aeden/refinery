require File.dirname(__FILE__) + '/../test_helper'
class ProcessorTest < Test::Unit::TestCase
  context "a processor" do
    setup do
      @server = stub('Server')
      @settings = {
        'workers' => {
          'initial' => 1
        }
      }
      
      @waiting_queue = stub('Queue(waiting)')
      @error_queue = stub('Queue(error)')
      @done_queue = stub('Queue(done)')
      
      Refinery::Daemon.any_instance.stubs(:require).with('java').raises(LoadError)
      Refinery::Daemon.any_instance.stubs(:queue).with(
      'sample_waiting').returns(@waiting_queue)
      Refinery::Daemon.any_instance.stubs(:queue).with(
      'sample_error').returns(@error_queue)
      Refinery::Daemon.any_instance.stubs(:queue).with(
      'sample_done').returns(@done_queue)
    end
    should "initialize" do
      assert_nothing_raised do
        @waiting_queue.stubs(:receive)
        Refinery::Processor.new(@server, 'sample', @settings)
      end
    end
  end
end