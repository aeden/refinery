require 'test_helper'

class UtilitiesIncluded
  include Refinery::Utilities
end

class UtilitiesTest < Test::Unit::TestCase
  context "a class with utilities included" do
    setup do
      @o = UtilitiesIncluded.new
    end
    should "camelize a word" do
      
      assert_equal 'ClassName', @o.camelize('class_name')
    end
    should "encode and decode message" do
      message = {'some' => 'message'}
      assert_equal message, @o.decode_message(@o.encode_message(message))
    end
    should "provide host info" do
      assert_not_nil @o.host_info['pid']
      assert_not_nil @o.host_info['hostname']
    end
  end
end