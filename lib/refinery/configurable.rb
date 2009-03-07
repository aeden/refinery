module Refinery #:nodoc:
  # Include this module to get access to a shared configuration
  module Configurable
    # Get the configuration. If the config is nil then this will use
    # the default shared configuration.
    def config
      @config ||= Refinery::Config.default
    end
    
    # Set the configuration.
    def config=(config)
      @config = config
    end
  end
end