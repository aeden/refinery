require 'test_helper'

class ValidatedWorker < Refinery::Worker
  include Refinery::Validations
  validate_with do |message|
    raise Refinery::InvalidMessageError, "A message is required" unless message
  end
  validates_key_exists :test
  
  def execute(message)
  end
end
class ValidationsTest < Test::Unit::TestCase
  context "a validated worker" do
    setup do
      daemon = stub('daemon')
      @worker = ValidatedWorker.new(daemon)
    end
    should "raise a validation error if the key does not exist" do
      message = {}
      assert_raise Refinery::InvalidMessageError do
        @worker.run(message)
      end
    end
    should "not raise a validation error if the key does exist" do
      message = {:test => 'ding!'}
      assert_nothing_raised do
        @worker.run(message)
      end
    end
    should "raise a validation error if the message is nil" do
      assert_raise Refinery::InvalidMessageError do
        @worker.run(nil)
      end
    end
  end
end