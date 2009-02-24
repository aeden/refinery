require File.dirname(__FILE__) + '/../test_helper'

class ConfigTest < Test::Unit::TestCase
  context "the config class" do
    should "provide a default configuration" do
      assert_not_nil Refinery::Config.default
    end
    context "defaults" do
      should "have an initial_number_of_daemons" do
        assert_equal 3, Refinery::Config.default['server']['initial_number_of_daemons']
      end
    end
    
    context "after loading configuration from a YAML file" do
      setup do
        @config = Refinery::Config.new
        @config.load_file(File.dirname(__FILE__) + '/../config.yml')
      end
      should "have the correct value for initial_number_of_daemons" do
        assert_equal 2, @config['server']['initial_number_of_daemons']
      end
      should "have aws credentials" do
        assert_equal 'aaa', @config['aws']['credentials']['access_key_id']
        assert_equal 'bbb', @config['aws']['credentials']['secret_access_key']
      end
    end
  end
end