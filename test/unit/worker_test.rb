require 'test_helper'

class SampleWorker < Refinery::Worker
  attr_reader :message
  def execute(message)
    @message = message
  end
end

class WorkerTest < Test::Unit::TestCase
  context "a worker" do
    setup do
      daemon = stub('daemon')
      @worker = SampleWorker.new(daemon)
      @message = {'test' => 'value'}
    end
    should "run" do
      @worker.run(@message)
      assert_equal @message, @worker.message
    end
    should "provide a data store" do
      options = {:bucket => 'bucket'}
      
      data_store = stub('data store')
      
      Moneta::S3.expects(:new).with(
        :access_key_id => 'aki',  
        :secret_access_key => 'sak',
        :bucket => options[:bucket],
        :multi_thread => true
      ).returns(data_store)
      
      setup_default_config
      assert_not_nil @worker.data_store(options)
    end
    should "provide a queue" do
      queue = stub('queue')
      queue_provider = stub('queue provider')
      queue_provider.expects(:queue).with('a_queue').returns(queue)
      @worker.expects(:queue_provider).returns(queue_provider)      
      assert_not_nil @worker.queue('a_queue')
    end
  end
end