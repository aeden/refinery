module Refinery #:nodoc:
  # The StatsServer class provides a build in web server that provides
  # a view into the refinery statistics.
  class StatsServer
    include Refinery::Loggable
    
    # Run the stats server.
    def run
      begin
        Ramaze::Log.loggers.clear # supress all Ramaze logging
        Ramaze.start              # start the Ramaze server on port 7000
      rescue NameError
        self.logger.warn "Install Remaze to enable the stats server"
      end
    end
    
    if const_defined?(:Ramaze)
      class MainController < ::Ramaze::Controller #:nodoc:
        map '/'
    
        def index
          %(
            <html>
            <head>
            <title>Refinery Stats</title>
            <style>
            .widget { border: 1px solid #777; margin-bottom: 10px; padding: 4px; }
            .widget h2 { font-size: 14pt; margin-top: 2px; margin-bottom: 2px; }
            #left-column { float: left; width: 600px; }
            #right-column { margin-left: 610px; width: 300px; }
            table { background-color: #ddd; width: 100%; }
            table td { background-color: #eee; }
            table th { background-color: #ccc; }
            </style>
            </head>
            <body>
            <h1>Refinery Stats</h1>
            <div id="left-column">
              <div class="run_time widget">
                <h2>Runtime Averages</h2>
                #{avg_run_time}
              </div>
              <div class="errors widget">
                <h2>Last 5 Errors</h2>
                #{errors_table}
              </div>
              <div class="completed widget">
                <h2>Last 5 Completed Jobs</h2>
                #{completed_jobs_table}
              </div>
            </div>
            <div id="right-column">
              <div class="overview widget">
                <h2>Overview</h2>
                <div>#{db[:completed_jobs].count} jobs completed</div>
                <div>#{db[:errors].count} errors</div>
              </div>
          
            </div>
            </body>
            </html>
          )
        end
    
        private
        def db
          Sequel.connect("sqlite://stats.db")
        end
    
        def avg_run_time
          rows = db[:completed_jobs].group(:host, :pid).select(:host, :pid, :AVG.sql_function(:run_time)).map do |record| 
            %(<tr>
            <td>#{record[:host]}</td>
            <td>#{record[:pid]}</td>
            <td>#{sprintf("%.6f", record[:"AVG(`run_time`)"])}</td>
            </tr>)
          end.join
          %(
            <table>
            <tr>
            <th>Host</th>
            <th>PID</th>
            <th>Avg Run Time</th>
            </tr>
            #{rows}
            </table>
          )
        end
    
        def completed_jobs_table
          jobs_list = db[:completed_jobs].limit(5).map do |record|
            %Q( <tr>
                <td>#{record[:host]}</td>
                <td>#{record[:pid]}</td>
                <td>#{record[:run_time]}</td>
                </tr>
            )
          end
          %Q( <table>
                <tr>
                  <th>Host</th>
                  <th>PID</th>
                  <th>Run Time</th>
                </tr>
                #{jobs_list.join}
              </table>
          )
        end
    
        def errors_table
          errors = db[:errors].limit(5).map do |record|
            %(<tr>
                <td>#{record[:host]}</td>
                <td>#{record[:pid]}</td>
                <td>#{record[:error_class]}</td>
                <td>#{record[:error_message]}</td>
              </tr>
            )
          end
          %(<table>
            <tr>
              <th>Host</th>
              <th>PID</th>
              <th>Error Class</th>
              <th>Error Message</th>
            </tr>
            #{errors.join}
            </table>
          )
        end
      end
    end
  end
end