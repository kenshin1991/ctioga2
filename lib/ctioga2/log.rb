# log.rb, copyright (c) 2006, 2007, 2009 by Vincent Fourmond: 
# The general logging functions for ctioga2
  
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
  
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details (in the COPYING file).

require 'ctioga2/utils'
require 'logger'

module CTioga2

  Version::register_svn_info('$Revision$', '$Date$')

  # This module should be included (or extended) by every class that
  # need logging/debugging facilities.
  module Log

    # Prints a debug message, on channel _channel_. Channel handling
    # is not implemented yet.
    def debug(channel = nil)
      @@logger.debug {yield}
    end

    # Prints a warning message
    def warn
      @@logger.warn {yield}
    end

    # Prints an informational message
    def info
      @@logger.info {yield}
    end

    # Prints an error message
    def error
      @@logger.error {yield}
    end

    # Prints a fatal error message and initiates program termination.
    def fatal
      @@logger.fatal {yield}
      exit 1                    # Fatal error.
    end

    # These are module functions:
    module_function :error, :debug, :warn, :info, :fatal

    # Format an exception for displaying
    def format_exception(e)
      return "#{e.class}: #{e.message}\n\t#{e.backtrace.join("\n\t")}"
    end

    def self.init_logger(stream = STDERR)
      Logger::Formatter::Format.replace("[%4$s] %6$s\n")
      @@logger = Logger.new(stream)
      @@logger.level = Logger::WARN # Warnings and more only by default
    end

    # Simple accessor for the @@log class variable.
    def self.logger
      return @@logger
    end

    # Sets the logging level.
    def self.set_level(level = Logger::WARN)
      @@logger.level = level
    end

    # A logged replacement for system
    def spawn(cmd, priority = :info)
      retval = system(cmd)
      self.send(priority) { "Spawned #{cmd} -> " + 
        if retval
          "success"
        else
          "failure"
        end
      }
      return retval
    end

    # Returns a string suitable for identification of an object, a bit
    # in the spirit of #inspect, but without displaying instance
    # variables.
    def identify(obj)
      return "#<%s 0x%x>" % [obj.class, obj.object_id]
    end

  end
end
