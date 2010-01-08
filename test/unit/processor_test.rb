require 'test_helper'

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
      
      provider = stub('QueueProvider')
      if defined?(Typica)
        Typica::Sqs::QueueService.stubs(:new).returns(provider)
      else
        RightAws::SqsGen2.stubs(:new).returns(provider)
      end
      provider.stubs(:queue).with('sample_waiting').returns(@waiting_queue)
      provider.stubs(:queue).with('sample_error').returns(@error_queue)
      provider.stubs(:queue).with('sample_done').returns(@done_queue)
    end
    should "initialize" do
      assert_nothing_raised do
        @waiting_queue.stubs(:receive)
        Refinery::Processor.new(@server, 'sample', @settings)
      end
    end
  end
end