module Refinery #:nodoc:
  # The statistics class provides a means to record runtime stats
  # about completed jobs and errors. The stats are stored in a SQL
  # database (using SQLite3 by default).
  class Statistics
    # Record the done record into the 
    def record_done(message)
      db[:completed_jobs] << {
        :host => message['host_info']['hostname'],
        :pid => message['host_info']['pid'],
        :run_time => message['run_time'],
        :original_message => message['original'],
        :when => Time.now
      }
    end
    
    # Record the error message into the statistics database.
    def record_error(message)
      db[:errors] << {
        :host => message['host_info']['hostname'],
        :pid => message['host_info']['pid'],
        :error_class => message['error']['class'],
        :error_message => message['error']['message'],
        :original_message => message['original'],
        :time => Time.now
      }
    end
    
    private
    # Get a Sequel connection to the stats database
    def db
      @db ||= begin
        db = Sequel.connect('sqlite://stats.db')
        unless db.table_exists?(:completed_jobs)
          db.create_table :completed_jobs do
            primary_key :id
            column :host, :text
            column :pid, :integer
            column :run_time, :float
            column :original_message, :text
            column :when, :time
          end
        end
        unless db.table_exists?(:errors)
          db.create_table :errors do
            primary_key :id
            column :host, :text
            column :pid, :integer
            column :error_class, :text
            column :error_message, :text
            column :original_message, :text
            column :when, :time
          end
        end
        db
      end
    end
  end
end