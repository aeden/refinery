require File.dirname(__FILE__) + '/../test_helper'

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
  end
end