from plothelpers import *
from sliders import * 

from Curves_yofx import nr_axes, common_sliders as common_sliders0

from Curves_yofx import plot


common_sliders = common_sliders0 + [vec2scalar, regions]

add_sliders, read_sliders = addread_sliders(*common_sliders)






