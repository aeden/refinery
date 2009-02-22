module RJob
  module Loggable
    def logger
      RJob::Server.logger
    end
  end
end