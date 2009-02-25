module Refinery #:nodoc:
  # Configuration class.
  class Config
    # Get a shared configuration
    def self.default
      @default ||= new({
        'aws' => {
          'credentials' => {}
        },
        'processors' => {}
      })
    end
    
    # Initialize the config with the given data
    def initialize(data={})
      @data = data
    end
    
    # Get the configuration value
    def [](key)
      data[key.to_s]
    end
    
    # Set the configuration value
    def []=(key, value)
      data[key.to_s] = value
    end
    
    # Load configuration from a YAML file
    def load_file(file)
      @file = file
      @data = YAML::load_file(@file)
      @last_load = File.mtime(@file)
    end
    
    # Refresh the configuration from the YAML file if necessary.
    def refresh
      if File.mtime(@file) != @last_load
        @data = YAML::load_file(@file)
      end
    end
    
    private
    def data
      @data ||= {}
    end
  end
end