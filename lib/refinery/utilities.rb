module Refinery #:nodoc:
  # Utilities that can be mixed into a class
  module Utilities
    # Camelize the given word.
    def camelize(word, first_letter_in_uppercase = true)
      if first_letter_in_uppercase
        word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
      else
        word.first.downcase + camelize(word)[1..-1]
      end
    end
    
    # Decode the message_body from Base 64 and then parse from JSON.
    def decode_message(message_body)
      JSON.parse(Base64.decode64(message_body))
    end
    
    # Convert the given message_data object to JSON and then Base 64
    # encode it
    def encode_message(message_data)
      Base64.encode64(message_data.to_json)
    end
    
    # Get a Hash of useful host information that can be sent with
    # messages to the monitoring system.
    def host_info
      {
        'hostname' => Socket.gethostname,
        'pid' => $$
      }
    end
  end
end