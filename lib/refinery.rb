$:.unshift(File.dirname(__FILE__))

require 'logger'

require 'rubygems'
require 'right_aws'
require 'json'

require 'refinery/loggable'
require 'refinery/configurable'

require 'refinery/config'
require 'refinery/heartbeat'
require 'refinery/server'
require 'refinery/daemon'
require 'refinery/event_publisher'
require 'refinery/publisher'

# The Refinery module contains all of the classes for the refinery system.
module Refinery
  # Raised if a source file cannot be loaded
  class SourceFileNotFound < RuntimeError
  end
end