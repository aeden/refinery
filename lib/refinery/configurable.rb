module Refinery #:nodoc:
  # Include this module to get access to a shared configuration
  module Configurable
    def config
      @config ||= Refinery::Config.default
    end
  end
end