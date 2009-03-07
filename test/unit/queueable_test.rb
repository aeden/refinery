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
      RightAws::SqsGen2.stubs(:new).with(
        'aki', 'sak', {:multi_thread => true}
      ).returns(queue)
      
      queueable = QueueMe.new
      assert_not_nil queueable.queue
    end
  end
end