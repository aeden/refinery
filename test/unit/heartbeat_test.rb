require File.dirname(__FILE__) + '/../test_helper'
class HeartbeatTest < Test::Unit::TestCase
  context "a heartbeat" do
    setup do
      setup_default_config
      
      @server = stub('server')
      @server.stubs(:daemons).returns([])
      
      heartbeat_queue = stub('heartbeat queue')
      heartbeat_queue.stubs(:send_message)
      queue_provider = stub('queue provider')
      queue_provider.expects(:queue).with('heartbeat').returns(heartbeat_queue)
      RightAws::SqsGen2.stubs(:new).with(
        'aki', 'sak', {:multi_thread => true}
      ).returns(queue_provider)
    end
    should "be initializable" do
      Refinery::Heartbeat.new(@server)
    end
  end
end