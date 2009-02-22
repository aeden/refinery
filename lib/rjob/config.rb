module RJob
  class Config
    attr_accessor :initial_number_of_daemons
    
    # Get a shared configuration
    def self.default
      @default ||= new
    end

    # Get the initial number of daemons to start when RJob launches
    def initial_number_of_daemons
      @initial_number_of_daemons ||= 3
    end
    
    # Get the Amazon Web Services configuration
    def aws
      @aws ||= Aws.new
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
    end
  end
  class ConfigurationError < RuntimeError
  end
  class Aws
    attr_accessor :credentials
    def credentials
      return @credentials if @credentials
      raise ConfigurationError, "You must specify AWS credentials"
    end
  end
end