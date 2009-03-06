$:.unshift(File.dirname(__FILE__))

require 'logger'
require 'benchmark'

# The Refinery module contains all of the classes for the refinery system.
module Refinery
  
  def self.require_library(short_name, display_name)
    begin
      require short_name
    rescue LoadError
      puts "#{display_name} is required, please install it"
      exit
    end
  end
  
  def self.require_libraries
    require_library('rubygems', 'Rubygems')
    require_library('right_aws', 'RightScale AWS gem')
    require_library('json', 'JSON gem')
  end
  
  def self.require_internals
    require 'refinery/loggable'
    require 'refinery/configurable'
    require 'refinery/queueable'

    require 'refinery/utilities'

    require 'refinery/config'
    require 'refinery/heartbeat'
    require 'refinery/server'
    require 'refinery/daemon'
    require 'refinery/worker'
    require 'refinery/event_publisher'
    require 'refinery/publisher'
  end
  
  # Raised if a source file cannot be loaded
  class SourceFileNotFound < RuntimeError
  end
end

Refinery::require_libraries
Refinery::require_internals