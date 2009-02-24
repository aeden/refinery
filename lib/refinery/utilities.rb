module Refinery
  module Utilities
    # Camelize the given word.
    def camelize(word, first_letter_in_uppercase = true)
      if first_letter_in_uppercase
        word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
      else
        word.first.downcase + camelize(word)[1..-1]
      end
    end
  end
end