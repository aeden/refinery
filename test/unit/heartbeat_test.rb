require File.dirname(__FILE__) + '/../test_helper'
class HeartbeatTest < Test::Unit::TestCase
  context "a heartbeat" do
    setup do
      setup_default_config
      
      @server = stub('server')
      @server.stubs(:daemons).returns([])
      
      heartbeat_queue = stub('heartbeat queue')
      heartbeat_queue.stubs(:send_message)
      provider = stub('queue provider')
      provider.stubs(:queue).with('heartbeat').returns(heartbeat_queue)
      if defined?(Typica)
        Typica::Sqs::QueueService.stubs(:new).returns(provider)
      else
        RightAws::SqsGen2.stubs(:new).returns(provider)
      end
    end
    should "be initializable" do
      Refinery::Heartbeat.new(@server)
    end
  end
end