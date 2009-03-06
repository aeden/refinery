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
    should_eventually "provide a data store" do
      options = {:bucket => 'bucket'}
      Refinery::Config.stubs(:default).returns(Refinery::Config.new(
        {
          'aws' => {
            'credentials' => {
              'access_key_id' => 'aki',
              'secret_access_key' => 'sak'
            }
          }
        }
      ))
      assert_not_nil @worker.data_store(options)
    end
  end
end