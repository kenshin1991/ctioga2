# styles.rb : Different Types to deal with various style arguments.
# Copyright (C) 2006, 2009 Vincent Fourmond
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA


require 'ctioga2/utils'

module CTioga2

  Version::register_svn_info('$Revision$', '$Date$')

  module MetaBuilder
    module Types

      # A color for use with Tioga, ie an [red, green, blue] array
      # of values between 0 and 1.0. It accepts HTML-like colors, or
      # three comma-separated values between 0 and 1.
      class TiogaColorType < Type
        
        type_name :tioga_color, 'color'
        
        def string_to_type_internal(str)
          if str =~ /#([0-9a-fA-F]{6})/
              value =  $1.scan(/../).map {
              |i| i.to_i(16)/255.0 
            }
          else 
            value = str.split(/\s*,\s*/).map do |s|
              s.to_f
            end
          end
          if value.size != 3
            raise IncorrectInput, "You need exactly three values to make up a color"
          end
          return value
        end
      end

      # A line style for Tioga. It will be represented as:
      # 
      #  a,b,c,d,...:e
      #  
      # This creates a line style of:
      # 
      #  [[a,b,c,d,...],e]
      #  
      # If the :e is omitted 0 is used.
      class LineStyleType < Type
        
        type_name :tioga_line_style, 'line_style'
        
        def string_to_type_internal(str)
          specs = str.split(/\s*,\s*/)
          if specs.last =~ /:(.*)$/
            phase = $1.to_f
            specs.last.gsub!(/:.*$/,'')
          else
            phase = 0
          end
          p specs
          return [ specs.map { |s| s.to_f }, phase]
        end
      end

      # A marker Type for Tioga. Input as
      # 
      #  a,b(,c)?
      #  
      class MarkerType < Type
        
        type_name :tioga_marker, 'marker'
        
        def string_to_type_internal(str)
          specs = str.split(/\s*,\s*/)
          if specs.size == 2
            return [specs[0].to_i, specs[1].to_i]
          elsif specs.size == 3
            return [specs[0].to_i, specs[1].to_i, specs[2].to_f]
          else
            raise IncorrectInput, "You need two or three values to make a marker"
          end
        end
      end

      # The type of edges/axis
      class AxisType < Type

        include Tioga::FigureConstants

        ValidTypes = {
          /hidden|off/i => AXIS_HIDDEN,
          /line/i => AXIS_LINE_ONLY, 
          /ticks/i => AXIS_WITH_TICKS_ONLY,
          /major/i => AXIS_WITH_MAJOR_TICKS_ONLY, 
          /major-num/i => AXIS_WITH_MAJOR_TICKS_AND_NUMERIC_LABELS,
          /full/i => AXIS_WITH_TICKS_AND_NUMERIC_LABELS
        }
        
        type_name :tioga_axis_type, 'axis_type'
        
        def string_to_type_internal(str)
          for k,v in ValidTypes
            if str =~ /^\s*#{k}\s*/
                return v
            end
          end
          raise IncorrectInput, "Not an axis type: #{str}"
        end
      end

      # Justification (horizontal alignement)
      class JustificationType < Type

        include Tioga::FigureConstants

        ValidTypes = {
          /l(eft)?/i => LEFT_JUSTIFIED,
          /c(enter)?/i => CENTERED,
          /r(ight)?/ => RIGHT_JUSTIFIED
        }
        
        type_name :tioga_justification, 'halign'
        
        def string_to_type_internal(str)
          for k,v in ValidTypes
            if str =~ /^\s*#{k}\s*/
                return v
            end
          end
          raise IncorrectInput, "Not a justification: #{str}"
        end
      end

      # Vertical alignement
      class AlignmentType < Type

        include Tioga::FigureConstants

        type_name :tioga_align, 'valign'
        
        ValidTypes = {
          /t(op)?/i => ALIGNED_AT_TOP,
          /c(enter)|m(idheight)/i => ALIGNED_AT_MIDHEIGHT,
          /B|Baseline|baseline/ => ALIGNED_AT_BASELINE,
          /b(ottom)?/ => ALIGNED_AT_BOTTOM
        }
        
        
        def string_to_type_internal(str)
          for k,v in ValidTypes
            if str =~ /^\s*#{k}\s*/
                return v
            end
          end
          raise IncorrectInput, "Not a vertical alignment: #{str}"
        end
      end

    end
  end
end