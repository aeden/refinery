module Refinery #:nodoc:
  # Error that is raised when a message is invalid.
  class InvalidMessageError < RuntimeError
  end
  
  # Module containing all validations.
  module Validations
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
    end
    
    # Class methods that are added to the worker.
    module ClassMethods
      # A list of all of the validators. Validators are lambdas
      # that will be called with the message as its only arg.
      # Note that the order of validators is retained.
      def validators
        @validators ||= []
      end
      
      # Validate with the given block. The block must receive a single
      # argument that is the message
      def validate_with(&block)
        validators << block
      end
      alias :validate :validate_with
      
      # Validate that each of the keys exists in the message.
      def validate_key_exists(*args)
        args.each do |key|
          validators << lambda do |message|
            raise Refinery::InvalidMessageError, "Key does not exist in message: #{key}" unless message[key]
          end
        end
      end
      alias :validates_key_exists :validate_key_exists
      alias :validates_presence_of :validate_key_exists
    end
    
    # Validate the given message
    protected
    def validate(message)
      self.class.validators.each do |validator|
        validator.call(message)
      end
    end
  end
end