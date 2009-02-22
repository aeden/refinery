module RJob
  class Config
    attr_accessor :initial_number_of_daemons
    
    def self.default
      @default ||= new
    end

    def initial_number_of_daemons
      @initial_number_of_daemons ||= 3
    end
  end
end