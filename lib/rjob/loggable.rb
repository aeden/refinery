module RJob
  # Include this module to get access to the server logger
  module Loggable
    def logger
      @logger ||= RJob::Server.logger
    end
  end
end