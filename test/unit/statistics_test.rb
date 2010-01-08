require 'test_helper'

if defined?(Sequel)
  class StatisticsTest < Test::Unit::TestCase
    context "a statistics instance" do
      should "record a done message" do
      
        dataset = stub('dataset')
        dataset.expects(:<<) # TODO: improve this expectation
      
        db = stub('db')
        db.stubs(:table_exists?).returns(true)
        db.stubs(:[]).with(:completed_jobs).returns(dataset)
      
        Sequel.expects(:connect).with('sqlite://stats.db').returns(db)
      
        message = {
          'host_info' => {'hostname' => 'test', 'pid' => 1},
          'run_time' => 1,
          'original' => ''
        }
        Refinery::Statistics.new.record_done(message)
      end
    
      should "record an error message" do
        dataset = stub('dataset')
        dataset.expects(:<<) # TODO: improve this expectation
      
        db = stub('db')
        db.stubs(:table_exists?).returns(true)
        db.stubs(:[]).with(:errors).returns(dataset)
      
        Sequel.expects(:connect).with('sqlite://stats.db').returns(db)
      
        message = {
          'host_info' => {'hostname' => 'test', 'pid' => 1},
          'error' => {'class' => 'Error', 'message' => 'An error occurred.'},
          'original' => ''
        }
        Refinery::Statistics.new.record_error(message)
      end
    end
  end
end