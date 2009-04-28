# curve.rb: style objects pertaining to curves and other line drawings.
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

# This module contains all the classes used by ctioga
module CTioga2

  Version::register_svn_info('$Revision$', '$Date$')

  module Graphics

    module Styles

      # A class holding all the styles for a curve.
      #
      # TODO: maybe for objects different than Curve2D, a subclass of
      # CurveStyle could be used ? This way, we could have clearly
      # separated legends and the like ?
      class CurveStyle

        # The style of the line that is drawn, as a StrokeStyle. 
        attr_accessor :line

        # The style of markers that should be drawn, as a MarkerStyle.
        attr_accessor :marker

        # The text of the legend, if there is one.
        attr_accessor :legend

        # True if a line should be drawn.
        def has_line?
          return @line && @line.style
        end

        # True if markers should be drawn
        def has_marker?
          return @marker && @marker.marker
        end

        # True if there is one legend to be drawn for this object.
        def has_legend?
          return @legend
        end

        # Sets the values of the different sub-objects from a 'flat'
        # _hash_. Keys have the following meaning:
        # * 'line_...': a StrokeStyle for the drawing the line
        # * 'marker_...': a MarkerStyle for the drawing of markers
        # * 'legend': the legend of the curve
        #
        # TODO: make @legend another object derived from BasicStyle ?
        def set_from_hash(hash)
          @line = StrokeStyle.from_hash(hash, 'line_%s')
          @marker = MarkerStyle.from_hash(hash, 'marker_%s')
          @legend = hash['legend']
        end

        # Creates a CurveStyle object straight from a hash
        # description. See #set_from_hash for more information.
        def self.from_hash(hash)
          a = CurveStyle.new
          a.set_from_hash(hash)
          return a
        end


        # Draws a legend pictogram that fills up the whole current
        # frame.
        #
        # TODO: add more elements to the pictogram in case of more
        # complex things.
        def draw_legend_pictogram(t)
          t.context do
            if has_line?
              @line.set_stroke_style(t)
              t.stroke_line(0.0, 0.5, 1.0, 0.5)
            end
            if has_marker?
              @marker.draw_markers_at(t, [0.5], [0.5])
            end
          end
        end


      end
    end
  end
end
