import numpy as np
import Plot,Algebra,Utils
from plothelpers import *
from sliders import *
from PartialObs import common_sliders as common_sliders0
from Z_vsX_vsEnergy import common_sliders as common_sliders1, nr_axes
from Z_vsX_vsEnergy import plot as plot0


local_sliders = common_sliders0 + common_sliders1 

                




#===========================================================================#
#
#   plot
#
#---------------------------------------------------------------------------#



def plot(Ax, get_plotdata, pobsmin=None, pobsmax=None, **kwargs):
    
    plot0(Ax, get_plotdata, zmin=pobsmin, zmax=pobsmax, **kwargs)




