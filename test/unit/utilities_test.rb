require File.dirname(__FILE__) + '/../test_helper'

class UtilitiesIncluded
  include Refinery::Utilities
end

class UtilitiesTest < Test::Unit::TestCase
  context "a class with utilities included" do
    should "camelize a word" do
      o = UtilitiesIncluded.new
      assert_equal 'ClassName', o.camelize('class_name')
    end
  end
end