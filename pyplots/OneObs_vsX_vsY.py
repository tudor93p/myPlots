import numpy as np
from plothelpers import *
from sliders import *
from Z_vsX_vsY import plot as plot0, common_sliders as common_sliders0
from Z_vsX_vsY import nr_axes



common_sliders = common_sliders0 + [obs_index, obs_vminmax]



#===========================================================================#
#
#   Plot
#
#---------------------------------------------------------------------------#



def plot(Ax, enlim=None, obsmin=None, obsmax=None, **kwargs):


    plot0(Ax, zmin=obsmin, zmax=obsmax, **kwargs) 

    

        












