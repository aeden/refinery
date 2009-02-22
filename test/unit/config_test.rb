require File.dirname(__FILE__) + '/../test_helper'

class ConfigTest < Test::Unit::TestCase
  context "the config class" do
    should "provide a default configuration" do
      assert_not_nil RJob::Config.default
    end
    context "defaults" do
      should "have an initial_number_of_daemons" do
        assert_equal 3, RJob::Config.default.initial_number_of_daemons
      end
    end
  end
end