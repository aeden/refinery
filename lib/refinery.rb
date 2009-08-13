$KCODE="UTF8"

$:.unshift(File.dirname(__FILE__))

require 'logger'
require 'socket'
require 'benchmark'

# The Refinery module contains all of the classes for the refinery system.
module Refinery
  
  # Require the specified library.
  #
  # The short name is the require path and the display_name will be shown
  # if the library cannot be loaded.
  def self.require_library(short_name, display_name)
    begin
      require short_name
    rescue LoadError
      puts "#{display_name} is required, please install it"
      exit
    end
  end
  
  # Require all of the dependencies.
  def self.require_libraries
    require_library('rubygems', 'Rubygems')
    require_library('right_aws', 'RightScale AWS gem')
    require_library('json', 'JSON gem')
    require_library('moneta', 'Moneta gem')
    require_library('moneta/s3', 'Moneta S3 implementation')
  end
  
  def self.require_optional_library(short_name, display_name)
    begin
      require short_name
      puts "#{short_name} optional library was loaded"
      true
    rescue LoadError
      puts "#{short_name} optional library not loaded"
    end
  end
  
  def self.require_optional_libraries
    require_optional_library('sequel', 'Sequel gem')
    require_optional_library('ramaze', 'Ramaze')
    
    if require_optional_library('java', 'JRuby')
      require_optional_library('typica', 'JRuby Typica wrapper')
    end
  end
  
  # Require internal code files
  def self.require_internals
    require 'thwait'
    
    require 'refinery/loggable'
    require 'refinery/configurable'
    require 'refinery/queueable'

    require 'refinery/utilities'
    
    require 'refinery/validations'

    require 'refinery/config'
    require 'refinery/heartbeat'
    require 'refinery/server'
    require 'refinery/processor'
    require 'refinery/daemon'
    require 'refinery/worker'
    require 'refinery/event_publisher'
    require 'refinery/publisher'
    require 'refinery/monitor'
    require 'refinery/statistics'
    require 'refinery/stats_server'
    
  end
  
  # Raised if a source file cannot be loaded
  class SourceFileNotFound < RuntimeError
  end
end

require 'net/http'
class Net::HTTP
  alias_method :old_initialize, :initialize
  def initialize(*args)
    old_initialize(*args)
    @ssl_context = OpenSSL::SSL::SSLContext.new
    @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
end

Refinery::require_libraries
Refinery::require_optional_libraries
Refinery::require_internals