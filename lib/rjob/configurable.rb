module RJob
  # Include this module to get access to a shared configuration
  module Configurable
    def config
      @config ||= RJob::Config.default
    end
  end
end