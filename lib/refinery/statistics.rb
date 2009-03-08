module Refinery
  class Statistics
    attr_reader :total_runs
    attr_reader :total_runtime

    def initialize
      @total_runs = 0
      @total_runtime = 0
    end
    
    def complete_run(run_time)
      @total_runs += 1
      @total_runtime += run_time
    end
    
    def average_runtime
      return 0 if total_runs == 0
      total_runtime / total_runs
    end
  end
end