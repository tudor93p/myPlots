from sliders import *

from Curves_yofx import nr_axes,plot,common_sliders as common_sliders0 

from SiteVectorScalarCut0 import common_sliders as common_sliders1


common_sliders = common_sliders1 + [choose_energy]


add_sliders, read_sliders = addread_sliders(*common_sliders,*common_sliders0)



