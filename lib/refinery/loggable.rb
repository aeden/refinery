module Refinery
  # Include this module to get access to the server logger
  module Loggable
    # Get the logger.
    def logger
      @logger ||= Refinery::Server.logger
    end
  end
end