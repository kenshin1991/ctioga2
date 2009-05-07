# markup.rb: simple markup system used wirhin the documentation.
# copyright (c) 2009 by Vincent Fourmond

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details (in the COPYING file).

require 'ctioga2/utils'
require 'ctioga2/log'

module CTioga2

  Version::register_svn_info('$Revision$', '$Date$')

  module Commands

    module Documentation

      # The documentation strings are written in a simple markup
      # language. 
      class MarkedUpText

        # Do we really need logging ?
        include Log

        # The base class for markup items.
        class MarkupItem
          # The documentation object
          attr_accessor :doc

          def initialize(doc)
            @doc = doc
          end

          def to_s
          end
        end

        # A markup item representing plain text.
        #
        # TODO: in to_s a simple word-wrapping algorithm could be
        # used.
        class MarkupText < MarkupItem
          # The text
          attr_accessor :text
          
          def initialize(doc, text = "", strip = true)
            super(doc)
            @text = text
            if strip
              @text.gsub!(/\n/, " ")
            end
          end

          def to_s
            return text
          end
        end

        # A markup item representing verbatim text, with the given
        # class
        class MarkupVerbatim < MarkupItem
          # The text
          attr_accessor :text

          # The verbatim text class
          attr_accessor :cls
          
          def initialize(doc, text, cls)
            super(doc)
            @text = text
            @cls = cls
          end

          def to_s
            return text
          end
        end

        # A link to a type/group/command
        class MarkupLink < MarkupItem
          # The object target of the link
          attr_accessor :target
          
          # _target_ is the name of the target, which can be of _type_
          # 'group', 'command' and 'type'.
          def initialize(doc, target, type)
            super(doc)
            @target = doc.send("#{type}s")[target]
          end

          def to_s
            if @target
              return @target.name
            else
              return "unknown"
            end
          end
        end

        # An itemize object 
        class MarkupItemize < MarkupItem

          # An array of arrays of MarkupItem, each representing an
          # element of the itemize object.
          attr_accessor :items
          
          def initialize(doc, items = [])
            super(doc)
            @items = items
          end
          
          def to_s
            str = ""
            for i in @items
              str << " * "
              for j in i
                str << j.to_s 
              end
              str << "\n"
            end
            return str
          end
        end

        # An item that contains a paragraph
        class MarkupParagraph < MarkupItem
          attr_accessor :elements
          
          def initialize(doc, elements)
            super(doc)
            @elements = elements
          end

          def to_s
            return @elements.map {|x| x.to_s }.join('')
          end
        end

        # The reference Doc object
        attr_accessor :doc

        # The elements that make up the MarkedUpText
        attr_accessor :elements

        # Creates a MarkedUpText object.
        def initialize(doc, text = nil)
          @elements = []
          @doc = doc
          if text
            parse_from_string(text)
          end
        end


        def dump
          puts "Number of elements: #{@elements.size}"
          for el in @elements
            puts "#{el.class} -> #{el.to_s}"
          end
        end


        # Parses the given _string_ and append the results to the
        # MarkedUpText's elements.
        #
        # Markup elements:
        #
        # * a line beginning with '> ' is an example for command-line
        # * a line beginning with '# ' is an example for use within a
        #   command file.
        # * a line beginning with ' *' is an element of an
        #   itemize. The itemize finishes when a new paragraph is
        #   starting.
        # * a {group: ...} or {type: ...} or {command: ...} is a link
        #   to the element.
        # * a blank line marks a paragraph break.
        def parse_from_string(string)
          @last_type = nil
          @last_string = ""

          lines = string.split(/\s*\n/)
          for l in lines
            case l
            when /^[#>]\s(.*)/  # a verbatim line
              type = (l[0] == '#' ? :cmdfile : :cmdline)
              if @last_type == type
                @last_string << "#{$1}\n"
              else
                flush_element
                @last_type = type
                @last_string = "#{$1}\n"
              end
            when /^\s\*\s*(.*)/
              flush_element
              @last_type = :item
              @last_string = "#{$1}\n"
            when /^\s*$/          # Blank line:
              flush_element
              @last_type = nil
              @last_string = ""
            else
              case @last_type
              when :item, :paragraph # simply go on
                @last_string << "#{l}\n"
              else
                flush_element
                @last_type = :paragraph
                @last_string = "#{l}\n"
              end
            end
          end
          flush_element
        end

        protected 

        # Parses the markup found within a paragraph (ie: links and
        # other text attributes, but not verbatim, list or other
        # markings) and returns an array containing the MarkupItem
        # elements.
        def parse_paragraph_markup(doc, string)
          els = []
          while string =~ /\{(group|type|command):\s*([^}]+?)\s*\}/
            els << MarkupText.new(doc, $`)
            els << MarkupLink.new(doc, $2, $1) 
            string = $'
          end
          els << MarkupText.new(doc, string)
          return els
        end

        # Adds the element accumulated so far to the @elements array.
        def flush_element
          case @last_type
          when :cmdline, :cmdfile
            @elements << MarkupVerbatim.new(@doc, @last_string, 
                                            "examples-#{@last_type}")
          when :paragraph
            @elements << 
              MarkupParagraph.new(@doc, 
                                  parse_paragraph_markup(doc, @last_string))
          when :item
            if @elements.last.is_a?(MarkupItemize)
              @elements.last.items << 
                parse_paragraph_markup(doc, @last_string)
            else
              @elements << 
                MarkupItemize.new(@doc, 
                                  [ parse_paragraph_markup(doc, @last_string)])
            end
          else                  # In principle, nil
            return
          end
        end


      end
    end

  end
end
