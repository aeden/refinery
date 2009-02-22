require File.dirname(__FILE__) + '/../test_helper'
class DaemonTest < Test::Unit::TestCase
  context "a daemon" do
    should "have logging" do
      assert_not_nil RJob::Daemon.new.logger
    end
    should "be startable" do
      assert_nothing_raised do
        server = stub('Server')
        RJob::Daemon.start(server, 1)
      end
    end
  end
end