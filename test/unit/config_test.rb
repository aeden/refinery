require 'test_helper'

class ConfigTest < Test::Unit::TestCase
  context "the config class" do
    should "provide a default configuration" do
      assert_not_nil Refinery::Config.default
    end
    
    context "default configuration" do
      setup do
        @config = Refinery::Config.default
      end
      should "provide an empty aws credentials hash" do
        assert_equal Hash.new, @config['aws']['credentials']
      end
      should "provide an empty processors hash" do
        assert_equal Hash.new, @config['processors']
      end
    end
    
    context "after loading configuration from a YAML file" do
      setup do
        @config_file = File.dirname(__FILE__) + '/../config.yml'
        @config = Refinery::Config.new
        @config.load_file(@config_file)
      end
      should "have aws credentials" do
        assert_equal 'aaa', @config['aws']['credentials']['access_key_id']
        assert_equal 'bbb', @config['aws']['credentials']['secret_access_key']
      end
      should "reload the file when changed" do
        `touch #{@config_file}`
        YAML.expects(:load_file).once
        @config.refresh
      end
      should "not reload the file when not changed" do
        YAML.expects(:load_file).never
        @config.refresh
      end
    end
  end
end