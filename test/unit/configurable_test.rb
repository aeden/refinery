require File.dirname(__FILE__) + '/../test_helper'
class ConfigureMe
  include Refinery::Configurable
end
class ConfigurableTest < Test::Unit::TestCase
  context "a class with the configurable module" do
    should "provide a config" do
      assert_not_nil ConfigureMe.new.config
    end
  end
end