module Refinery #:nodoc:
  # Configuration class.
  class Config
    attr_accessor :initial_number_of_daemons
    attr_accessor :publishing
    
    # Get a shared configuration
    def self.default
      @default ||= new
    end

    # Get the initial number of daemons to start when Refinery launches
    def initial_number_of_daemons
      @initial_number_of_daemons ||= 3
    end
    
    # Get the Amazon Web Services configuration
    def aws
      @aws ||= Aws.new
    end
    
    def publishing
      @publishing ||= []
    end
    
    # Load configuration from a YAML file
    def load_file(file)
      config_yaml = YAML::load_file(file)
      if config_yaml["initial_number_of_daemons"]
        self.initial_number_of_daemons = config_yaml["initial_number_of_daemons"]
      end
      if (aws_yaml = config_yaml["aws"])
        self.aws.credentials = aws_yaml['credentials']
      end
      if (publishing = config_yaml["publishing"])
        self.publishing = publishing
      end
    end
  end
  
  # Error that is raised when misconfigured.
  class ConfigurationError < RuntimeError
  end
  
  # AWS configuration items
  class Aws
    # Read and write the credentials. The credentials must be a Hash that
    # includes two keys: access_key_id and secret_access_key.
    attr_accessor :credentials

    def credentials #:nodoc:
      return @credentials if @credentials
      raise ConfigurationError, "You must specify AWS credentials"
    end
  end
end