# drawable.rb: style objects pertaining to drawable objects.
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

    # All the styles
    module Styles

      # This class represents all the stylistic information to stroke
      # a Tioga path.
      class StrokeStyle < BasicStyle
        # The color
        attr_accessor :color
        
        # The line style
        attr_accessor :style

        # The line width
        attr_accessor :width

        # Sets the stroke style to a FigureMaker object, _t_.
        def set_stroke_style(t)
          t.stroke_color = @color if @color
          t.line_type = @style if @style
          t.line_width = @width if @width
        end
      end

      # This class represents all the stylistic information to draw a
      # Marker.
      #
      # \todo many things are still missing here...
      # 
      # * in particular, angles could be handled here, and they could
      #   be handled directly in the marker specification...
      class MarkerStyle < BasicStyle

        # The color
        attr_accessor :color
        
        # The marker
        attr_accessor :marker

        # The marker scale
        attr_accessor :scale

        # Shows the marker at a given location/set of locations.
        # 
        # \p override is a hash that can override part of the
        # dictionnary specification.
        def draw_markers_at(t, x, y, override = nil)
          t.context do
            ## \todo allow custom line types for markers ?
            t.line_type = LineStyles::Solid
            dict = { 
              'marker' => @marker, 
              'color' => @color
            }
            if x.is_a? Numeric
              dict['x'] = x
              dict['y'] = y
            else
              dict['Xs'] = x
              dict['Ys'] = y
            end

            if @scale
              dict['scale'] = @scale
            end
            if override
              dict.merge!(override)
            end
            t.show_marker(dict)
          end
        end
      end

      # A style that handles drawing a fill.
      #
      # \todo add ways to specify complex fills, such as patterned
      # fills and so on. Those would use clipping the path and base
      # themselves on the coordinates of the current frame.
      #
      # \todo more attributes ?
      class FillStyle < BasicStyle

        # The color.
        attr_accessor :color

        # The transparency
        attr_accessor :transparency

        # Sets up the parameters for the fill. Must be called before
        # any path drawing.
        #
        # \warning You *must* call FillStyle#do_fill for
        # filling. Directly calling FigureMaker#fill is not a good
        # idea, as you lose all 'hand-crafted' fills !
        def setup_fill(t)
          t.fill_color = @color if @color
          t.fill_transparency = @transparency if @transparency
        end

        # Does the actual filling step. Must be used within a context,
        # as it quite messes up with many things. Must be called after
        # a call to #setup_fill.
        def do_fill(t)
          t.fill
        end

      end

      # Same as FillStyle, but with additional parameters that handle
      # how the fill should be applied to curves.
      class CurveFillStyle < FillStyle

        # At which Y value we should draw the horizontal line for the
        # fill ? A float, or:
        # * :top, :bottom
        # * false, nil to disable filling altogether
        attr_accessor :y0
        
      end

    end
  end
end

