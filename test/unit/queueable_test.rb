require File.dirname(__FILE__) + '/../test_helper'

class QueueMe
  include Refinery::Configurable
  include Refinery::Queueable
end

class QueueableTest < Test::Unit::TestCase
  context "a class with the Queuable module" do
    should "provide a queue" do
      setup_default_config
      
      queue = stub('queue')
      queue_provider = stub('queue provider')
      queue_provider.expects(:queue).with('a_queue').returns(queue)
      RightAws::SqsGen2.expects(:new).with(
        'aki', 'sak', {:multi_thread => true}
      ).returns(queue_provider)
      
      queueable = QueueMe.new
      assert_not_nil queueable.queue('a_queue')
    end
  end
end