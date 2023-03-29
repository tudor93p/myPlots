import numpy as np
import Plot,Algebra,Utils
from plothelpers import *
from sliders import *
from Curves_yofx import nr_axes, common_sliders as common_sliders0
from Curves_yofx import plot as plot0


common_sliders = [partial_observables, partobs_vminmax, boundaries, smoothen]

local_sliders = common_sliders0 + common_sliders + [choose_energy]
                




#===========================================================================#
#
#   plot
#
#---------------------------------------------------------------------------#



def plot(Ax, pobsmin=None, pobsmax=None, **kwargs):
   

    plot0(Ax, ylim=[pobsmin,pobsmax], **kwargs)




