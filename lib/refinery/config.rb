require 'ostruct'

module Refinery #:nodoc:
  # Configuration class.
  class Config
    # Get a shared configuration
    def self.default
      @default ||= new({
        'server' => {
          'initial_number_of_daemons' => 3
        },
        'aws' => {
          'credentials' => {}
        },
        'processors' => {}
      })
    end
    
    def initialize(data={})
      @data = data
    end
    
    def [](key)
      data[key.to_s]
    end
    
    def []=(key, value)
      data[key.to_s] = value
    end
    
    # Load configuration from a YAML file
    def load_file(file)
      @data = YAML::load_file(file)
    end
    
    private
    def data
      @data ||= {}
    end
  end
end