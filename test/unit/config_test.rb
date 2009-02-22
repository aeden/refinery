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
    
    should "raise a configuration error if aws credentials are not set" do
      assert_raise RJob::ConfigurationError do
        RJob::Config.default.aws.credentials
      end
    end
    should "not raise a configuration error if aws credentials are set" do
      config = RJob::Config.new
      aws = config.aws
      credentials = {
        'access_key_id' => 'xxx',
        'secret_access_key' => 'yyy'
      }
      aws.credentials = credentials
      assert_equal credentials, aws.credentials
    end
    
    context "after loading configuration from a YAML file" do
      setup do
        @config = RJob::Config.new
        @config.load_file(File.dirname(__FILE__) + '/../config.yml')
      end
      should "have the correct value for initial_number_of_daemons" do
        assert_equal 2, @config.initial_number_of_daemons
      end
      should "have aws credentials" do
        assert_equal 'aaa', @config.aws.credentials['access_key_id']
        assert_equal 'bbb', @config.aws.credentials['secret_access_key']
      end
    end
  end
end